using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace CharacterToon.Editor
{
    /// <summary>
    /// FBX(모델) 임포트 시 외곽선용 스무스 노멀을 메시 TANGENT.xyz 에 '자동' 베이크한다.
    /// → 수동 베이크/별도 _SmoothOutline 메시 재할당이 영구히 불필요. FBX를 갱신/재임포트만 해도 적용.
    ///
    /// 안전성: 포워드 패스 노멀맵은 픽셀 미분 코탄젠트 프레임을 쓰므로 tangent를 점유해도 충돌 없음
    ///   (결정 #3). FBX의 모든 메시(서브메시 포함)를 한 번에 처리하므로 "FBX 전체 한번에" 요구도 충족.
    ///
    /// 스코프(중요): Project Settings > CharacterToon 의 폴더 목록 하위 모델만 처리한다(무관한 모델 보호).
    ///   - 기본값은 이 저작 프로젝트의 Assets/Sample/FBX. 패키지를 쓰는 프로젝트는 자기 캐릭터 폴더를 추가한다.
    ///     (예전엔 "/sample/fbx/" 가 코드에 박혀 있어 다른 프로젝트에선 폴더 자동 베이크가 아예 안 됐다.)
    ///   - 특정 FBX만 자동 베이크에서 빼려면 파일명에 OptOutSuffix("_nosmooth")를 포함.
    ///   - 폴더와 무관하게 단일 베이크 툴로 등록(userData)된 FBX는 항상 처리.
    /// </summary>
    public class SmoothNormalModelPostprocessor : AssetPostprocessor
    {
        private const string OptOutSuffix = "_nosmooth";

        // 단일 베이크 툴이 모델 임포터 userData 에 per-FBX 허용치를 등록할 때 쓰는 키.
        public const string ToleranceKey = "CTSmoothWeld";

        private static bool PathInScope(string path)
        {
            string p = path.Replace("\\", "/").ToLowerInvariant();
            if (p.Contains(OptOutSuffix)) return false;
            foreach (string folder in CharacterToonProjectSettings.instance.smoothNormalFolders)
            {
                if (string.IsNullOrWhiteSpace(folder)) continue;
                string f = folder.Replace("\\", "/").Trim().TrimEnd('/').ToLowerInvariant() + "/";
                if (p.StartsWith(f)) return true;
            }
            return false;
        }

        // ── per-FBX 허용치 등록(userData) 헬퍼: 단일 베이크 툴과 공유 ──
        // userData 는 "key=value;key=value" 세그먼트로 다루어 다른 데이터와 공존.
        public static bool TryGetRegisteredTolerance(string userData, out float tol)
        {
            tol = SmoothNormalUtil.DefaultWeldTolerance;
            if (string.IsNullOrEmpty(userData)) return false;
            foreach (string seg in userData.Split(';'))
            {
                int eq = seg.IndexOf('=');
                if (eq > 0 && seg.Substring(0, eq).Trim() == ToleranceKey &&
                    float.TryParse(seg.Substring(eq + 1).Trim(),
                        System.Globalization.NumberStyles.Float,
                        System.Globalization.CultureInfo.InvariantCulture, out float v))
                {
                    tol = v;
                    return true;
                }
            }
            return false;
        }

        public static void SetRegisteredTolerance(ModelImporter mi, float tol)
        {
            var segs = SegmentsWithout(mi.userData, ToleranceKey);
            segs.Add($"{ToleranceKey}={tol.ToString(System.Globalization.CultureInfo.InvariantCulture)}");
            mi.userData = string.Join(";", segs);
        }

        public static void ClearRegisteredTolerance(ModelImporter mi)
        {
            mi.userData = string.Join(";", SegmentsWithout(mi.userData, ToleranceKey));
        }

        private static List<string> SegmentsWithout(string userData, string key)
        {
            var segs = new List<string>();
            if (!string.IsNullOrEmpty(userData))
                foreach (string seg in userData.Split(';'))
                    if (!string.IsNullOrWhiteSpace(seg) && !seg.TrimStart().StartsWith(key + "="))
                        segs.Add(seg);
            return segs;
        }

        // 임포트 직후 호출 — 이 시점에 mesh.tangents 를 써넣으면 임포트 결과에 영구 반영된다.
        private void OnPostprocessModel(GameObject root)
        {
            // 허용치/대상 결정: 등록(userData)된 FBX는 그 허용치로 항상 처리, 아니면 폴더 스코프는 기본 허용치.
            var mi = assetImporter as ModelImporter;
            float tol = SmoothNormalUtil.DefaultWeldTolerance;   // 단축평가로 TryGet이 호출 안 될 때 대비해 미리 초기화
            bool registered = mi != null && TryGetRegisteredTolerance(mi.userData, out tol);
            if (!registered && !PathInScope(assetPath)) return;

            var done = new HashSet<Mesh>();   // 공유 메시 중복 처리 방지
            int count = 0;

            foreach (var mf in root.GetComponentsInChildren<MeshFilter>(true))
            {
                if (mf.sharedMesh != null && done.Add(mf.sharedMesh))
                {
                    SmoothNormalUtil.BakeIntoTangents(mf.sharedMesh, tol);
                    count++;
                }
            }
            foreach (var smr in root.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            {
                if (smr.sharedMesh != null && done.Add(smr.sharedMesh))
                {
                    SmoothNormalUtil.BakeIntoTangents(smr.sharedMesh, tol);
                    count++;
                }
            }

            if (count > 0)
                Debug.Log($"[SmoothNormalModelPostprocessor] '{assetPath}' — {count}개 메시 스무스 노멀 자동 베이크(TANGENT), tol={tol}{(registered ? " (등록값)" : "")}.");
        }

        /// <summary>
        /// 스코프 내 모든 모델을 강제 재임포트 → 자동 베이크 일괄 적용("FBX 전체 한번에").
        /// 정책/스코프 변경 후, 또는 기존 모델에 처음 적용할 때 1회 실행.
        /// </summary>
        [MenuItem("Window/CharacterToon/Reimport Models (Auto Smooth Normals)")]
        public static void ReimportScopedModels()
        {
            string[] guids = AssetDatabase.FindAssets("t:Model");
            var paths = new List<string>();
            foreach (string g in guids)
            {
                string path = AssetDatabase.GUIDToAssetPath(g);
                bool registered = AssetImporter.GetAtPath(path) is ModelImporter mi &&
                                  TryGetRegisteredTolerance(mi.userData, out _);
                if (registered || PathInScope(path)) paths.Add(path);
            }

            if (paths.Count == 0)
            {
                EditorUtility.DisplayDialog("Auto Smooth Normals",
                    "스코프 내 모델을 찾지 못했습니다.\nProject Settings > CharacterToon 의 폴더 목록을 확인하세요.", "OK");
                return;
            }

            AssetDatabase.StartAssetEditing();
            try
            {
                foreach (string path in paths)
                    AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
            }
            finally
            {
                AssetDatabase.StopAssetEditing();
            }
            AssetDatabase.Refresh();

            EditorUtility.DisplayDialog("Auto Smooth Normals",
                $"{paths.Count}개 모델 재임포트 완료 — 외곽선 스무스 노멀이 메시 TANGENT에 자동 베이크되었습니다.", "OK");
            Debug.Log($"[SmoothNormalModelPostprocessor] {paths.Count}개 모델 재임포트(자동 스무스 노멀).");
        }
    }
}
