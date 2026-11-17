using UnityEngine;

namespace CharacterToon
{
    /// <summary>
    /// 얼굴 방향 벡터(_FaceForwardWS, _FaceRightWS)를 이 캐릭터의 얼굴 렌더러에만 넣는다.
    ///
    /// 예전에는 Shader.SetGlobalVector 로 넣어서 캐릭터가 둘 이상이면 모든 얼굴 SDF가 마지막에 쓴
    /// 캐릭터의 방향을 따랐다. 이제 값은 머티리얼 CBUFFER 프로퍼티이고, 렌더러별 MaterialPropertyBlock 으로
    /// 덮어쓴다. 같은 얼굴 머티리얼 에셋을 여러 캐릭터가 공유해도 섞이지 않고 에셋도 더럽히지 않는다.
    /// 대가: MPB 를 쓴 렌더러는 SRP Batcher 묶음에서 빠진다(캐릭터당 얼굴 드로우 몇 개).
    ///
    /// 대상 렌더러: 이 오브젝트와 자식 중 Part=Face(_PART_FACE) 머티리얼을 쓰는 것.
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public class CharacterToonFace : MonoBehaviour
    {
        [SerializeField]
        private Transform _faceAnchor;

        private static readonly int FaceForwardWSId = Shader.PropertyToID("_FaceForwardWS");
        private static readonly int FaceRightWSId = Shader.PropertyToID("_FaceRightWS");
        private static MaterialPropertyBlock s_block;

        private Renderer[] _faceRenderers;

        private void OnEnable()
        {
            _faceRenderers = FindFaceRenderers(transform);
            if (_faceRenderers.Length == 0)
                Debug.LogWarning($"[CharacterToonFace] '{name}' 아래에 Part=Face 머티리얼을 쓰는 렌더러가 없다. 얼굴 메시 오브젝트(또는 그 부모)에 붙일 것.", this);
        }

        private void LateUpdate()
        {
            if (_faceAnchor == null)
                return;
            foreach (Renderer r in _faceRenderers)
                Apply(r, _faceAnchor.forward, _faceAnchor.right);
        }

        /// <summary>렌더러 하나에 얼굴 방향을 넣는다. 그 렌더러의 다른 MPB 값은 보존한다.</summary>
        public static void Apply(Renderer renderer, Vector3 forward, Vector3 right)
        {
            if (renderer == null)
                return;
            s_block ??= new MaterialPropertyBlock();
            renderer.GetPropertyBlock(s_block);
            s_block.SetVector(FaceForwardWSId, forward);
            s_block.SetVector(FaceRightWSId, right);
            renderer.SetPropertyBlock(s_block);
        }

        /// <summary>Part=Face 머티리얼을 하나라도 쓰는 렌더러인가.</summary>
        public static bool IsFaceRenderer(Renderer r)
        {
            foreach (Material m in r.sharedMaterials)
                if (m != null && m.IsKeywordEnabled("_PART_FACE"))
                    return true;
            return false;
        }

        /// <summary>root 와 그 자식 중 얼굴 렌더러.</summary>
        public static Renderer[] FindFaceRenderers(Transform root) =>
            System.Array.FindAll(root.GetComponentsInChildren<Renderer>(true), IsFaceRenderer);
    }
}
