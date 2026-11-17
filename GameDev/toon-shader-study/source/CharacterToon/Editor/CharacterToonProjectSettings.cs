using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace CharacterToon.Editor
{
    /// <summary>
    /// 프로젝트 단위 CharacterToon 설정(ProjectSettings/CharacterToonSettings.asset, VCS 로 공유).
    /// Project Settings > CharacterToon 에서 편집한다.
    /// </summary>
    [FilePath("ProjectSettings/CharacterToonSettings.asset", FilePathAttribute.Location.ProjectFolder)]
    public class CharacterToonProjectSettings : ScriptableSingleton<CharacterToonProjectSettings>
    {
        [Tooltip("이 폴더(하위 포함)의 모델은 임포트 때 외곽선용 스무스 노멀을 TANGENT 에 자동 베이크한다. " +
                 "프로젝트 기준 경로(예: Assets/Characters). 파일명에 _nosmooth 가 있으면 제외.")]
        public List<string> smoothNormalFolders = new List<string> { "Assets/Sample/FBX" };

        public void SaveSettings() => Save(true);

        [SettingsProvider]
        private static SettingsProvider CreateProvider() =>
            new SettingsProvider("Project/CharacterToon", SettingsScope.Project)
            {
                guiHandler = _ =>
                {
                    var so = new SerializedObject(instance);
                    EditorGUILayout.PropertyField(so.FindProperty(nameof(smoothNormalFolders)),
                        new GUIContent("Auto Smooth Normal Folders"), true);
                    if (so.ApplyModifiedPropertiesWithoutUndo())
                        instance.SaveSettings();
                    EditorGUILayout.HelpBox("폴더를 바꾼 뒤 기존 모델에 적용하려면 Window > CharacterToon > Reimport Models (Auto Smooth Normals).", MessageType.Info);
                },
            };
    }
}
