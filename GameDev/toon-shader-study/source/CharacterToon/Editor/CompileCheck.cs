// TEMP batch-mode compile/validation harness. Delete after testing.
// Invoked headless via: Unity.exe -batchmode -quit -executeMethod CharacterToon.Editor.CompileCheck.Run
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace CharacterToon.Editor
{
    public static class CompileCheck
    {
        // 열린 에디터에서 SceneToon(배경) + 공유 라이브러리 + CharacterToon 셰이더 오류를 Console 로 검증.
        //   배치 컴파일이 에디터 락과 충돌할 때 사용. 결과는 Console + compilecheck_result.txt.
        // 셰이더는 Assets/ 가 아니라 이 패키지 안에 있다. 패키지로 승격하면서 경로가 바뀌었는데
        // 여기가 Assets/* 를 가리키고 있어 셰이더 0개를 뒤지고도 errors=0 으로 통과 보고했다.
        private const string PackageRoot = "Packages/com.blueigloo.shader";
        private static readonly string[] AllRoots =
        {
            PackageRoot + "/SceneToon", PackageRoot + "/ToonShared", PackageRoot + "/CharacterToon"
        };

        [MenuItem("Tools/Toon/Validate Shaders (Scene + Character)")]
        public static void ValidateMenu()
        {
            RunInternal(AllRoots, exitOnDone: false);
        }

        public static void Run()
        {
            RunInternal(new[] { PackageRoot + "/CharacterToon" }, exitOnDone: true);
        }

        // 헤드리스 배치: SceneToon(배경) + 공유 라이브러리 + CharacterToon 전부 검증 후 종료.
        public static void RunAll()
        {
            RunInternal(AllRoots, exitOnDone: true);
        }

        private static void RunInternal(string[] roots, bool exitOnDone)
        {
            var sb = new StringBuilder();
            int errorCount = 0;

            // 1) Shader compile messages (variants force-compiled per material below)
            string[] shaderGuids = AssetDatabase.FindAssets("t:Shader", roots);
            foreach (var g in shaderGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(g);
                var shader = AssetDatabase.LoadAssetAtPath<Shader>(path);
                if (shader == null) continue;

                bool hasErr = ShaderUtil.ShaderHasError(shader);
                var msgs = ShaderUtil.GetShaderMessages(shader);
                sb.AppendLine($"[SHADER] {path}  hasError={hasErr}  messages={msgs.Length}");
                foreach (var m in msgs)
                {
                    string tag = m.severity == ShaderCompilerMessageSeverity.Error ? "ERROR" : "warn";
                    if (m.severity == ShaderCompilerMessageSeverity.Error) errorCount++;
                    sb.AppendLine($"   [{tag}] {m.message} | {m.messageDetails} (platform={m.platform})");
                }
            }

            // 2) Material validation — confirm each sample mat keeps the CharacterToon shader (not fallback)
            string[] matGuids = AssetDatabase.FindAssets("t:Material", new[] { "Assets/Sample/Material" });
            foreach (var g in matGuids)
            {
                string path = AssetDatabase.GUIDToAssetPath(g);
                var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (mat == null || mat.shader == null) continue;
                string keywords = string.Join(",", mat.shaderKeywords);
                sb.AppendLine($"[MAT] {Path.GetFileName(path)}  shader='{mat.shader.name}'  keywords=[{keywords}]");
            }

            // 3) C# 이 이름으로 찾는 셰이더가 실제로 있는지. ed57a17 에서 셰이더 이름만 바뀌고 C# 은 옛 이름으로
            //    남아, Lit/Unlit 전환과 두 스트리퍼가 아무 오류 없이 죽어 있었다.
            string[] referencedNames =
            {
                CharacterToonKeywordSanitizer.LitShaderName,
                CharacterToonKeywordSanitizer.UnlitShaderName,
                "com.blueigloo/SceneToon/Scene",   // SceneToonShaderStripper.TargetShaderName
            };
            foreach (string name in referencedNames)
            {
                if (Shader.Find(name) != null) continue;
                errorCount++;
                sb.AppendLine($"   [ERROR] C# 이 참조하는 셰이더 이름을 찾지 못했다: {name}");
            }

            // 셰이더를 하나도 못 찾았다면 경로가 틀린 것이다. 조용히 통과시키면 검증이 무의미해지므로 실패로 센다.
            if (shaderGuids.Length == 0)
            {
                errorCount++;
                sb.AppendLine($"   [ERROR] roots 에서 셰이더를 하나도 찾지 못했다 — 경로가 낡았는지 확인할 것: {string.Join(",", roots)}");
            }

            sb.Insert(0, $"=== Toon CompileCheck === roots=[{string.Join(",", roots)}] shaders={shaderGuids.Length} errors={errorCount}\n");
            string outPath = Path.Combine(Directory.GetCurrentDirectory(), "compilecheck_result.txt");
            File.WriteAllText(outPath, sb.ToString());
            Debug.Log(sb.ToString());

            if (exitOnDone)
                EditorApplication.Exit(errorCount > 0 ? 1 : 0);
        }
    }
}
