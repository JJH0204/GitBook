using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace CharacterToon.Editor
{
    /// <summary>
    /// 파트(_PART_*)와 맞지 않는 기능 키워드를 머티리얼에서 끈다.
    ///
    /// 셰이더는 이 키워드들을 파트 #if 안에서만 쓰므로 픽셀 결과는 같다. 그런데 shader_feature 는
    /// 머티리얼이 실제로 켠 조합만 빌드에 컴파일하므로, 스트리퍼가 "파트 불일치 조합"을 지우면
    /// 그 머티리얼은 쓸 배리언트를 잃는다(같은 조합의 '기능 off' 변형은 아무도 안 써서 애초에 없다).
    /// _UseAngelRing 기본값이 1 이라 헤어가 아닌 머티리얼 대부분이 _USE_ANGELRING 을 켠 채였다.
    /// 그래서 스트리퍼보다 먼저 머티리얼 쪽을 정리한다: 인스펙터(ValidateMaterial)와 빌드 직전.
    /// 같은 자리에서 아웃라인 토글에 맞춰 Outline 패스 활성 상태도 맞춘다(B4).
    /// </summary>
    public class CharacterToonKeywordSanitizer : IPreprocessBuildWithReport
    {
        public const string LitShaderName = "com.blueigloo/CharacterToon/Character";
        public const string UnlitShaderName = "com.blueigloo/CharacterToon/Character Unlit";
        private const string OutlinePassTag = "SRPDefaultUnlit";   // Outline 패스의 LightMode (SetShaderPassEnabled 는 태그로 찾는다)

        // 기능 키워드 → 그 기능이 동작하는 유일한 파트 (CharacterToon.shader 의 #if 가드와 일치해야 함)
        private static readonly (string keyword, string part)[] PartOnly =
        {
            ("_USE_HAIR_SHADOW", "_PART_FACE"),
            ("_DEBUG_FACELIT", "_PART_FACE"),
            ("_USE_ANGELRING", "_PART_HAIR"),
            ("_USE_SSS", "_PART_SKIN"),
        };

        public static bool IsCharacterToon(Shader shader) =>
            shader != null && (shader.name == LitShaderName || shader.name == UnlitShaderName);

        /// <summary>파트와 맞지 않는 키워드를 끈다. forBuild 면 디버그 키워드도 끈다. 바뀌었으면 true.</summary>
        public static bool Sanitize(Material m, bool forBuild = false)
        {
            bool changed = false;
            foreach (var (keyword, part) in PartOnly)
            {
                if (m.IsKeywordEnabled(keyword) && !m.IsKeywordEnabled(part))
                {
                    m.DisableKeyword(keyword);
                    changed = true;
                }
            }
            // 디버그 뷰는 플레이어에 실리면 안 되고 스트리퍼가 지운다 → 빌드 전에 머티리얼에서도 끈다.
            // 토글 값도 0으로: 남겨 두면 프로퍼티 드로어 재적용 때 키워드가 되살아난다.
            bool debugValueOn = m.HasProperty("_DebugFaceLit") && m.GetFloat("_DebugFaceLit") != 0f;
            if (forBuild && (debugValueOn || m.IsKeywordEnabled("_DEBUG_FACELIT")))
            {
                m.DisableKeyword("_DEBUG_FACELIT");
                if (debugValueOn) m.SetFloat("_DebugFaceLit", 0f);
                changed = true;
            }
            // B4: 아웃라인을 끈 머티리얼은 Outline 패스(SRPDefaultUnlit) 자체를 끈다. 셰이더의 키워드 off 분기는
            //   정점을 화면 밖으로 보낼 뿐이라 드로우콜·스키닝된 정점 처리 비용은 그대로 남는다.
            bool outlineOn = m.IsKeywordEnabled("_USE_OUTLINE");
            if (m.GetShaderPassEnabled(OutlinePassTag) != outlineOn)
            {
                m.SetShaderPassEnabled(OutlinePassTag, outlineOn);
                changed = true;
            }
            return changed;
        }

        public int callbackOrder => 0;

        public void OnPreprocessBuild(BuildReport report)
        {
            int count = 0;
            foreach (string guid in AssetDatabase.FindAssets("t:Material"))
            {
                var m = AssetDatabase.LoadAssetAtPath<Material>(AssetDatabase.GUIDToAssetPath(guid));
                if (m == null || !IsCharacterToon(m.shader) || !Sanitize(m, forBuild: true))
                    continue;
                EditorUtility.SetDirty(m);
                count++;
            }
            if (count == 0)
                return;
            AssetDatabase.SaveAssets();
            Debug.Log($"[CharacterToonKeywordSanitizer] 빌드 전 머티리얼 {count}개에서 파트 불일치/디버그 키워드를 껐다.");
        }
    }
}
