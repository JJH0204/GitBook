# CSV 데이터 계층: DatabaseManager, EntryCloner, EntryModifierEvent

## 무엇이 바뀌었나

원본 GOS에는 데이터 개념이 없었다. 노드는 인스펙터에 직접 넣은 값만 썼다. 포크는 `VisualScripting/CustumData/`에 CSV를 읽어 표(테이블)로 들고 있는 계층을 추가하고, 그 표의 한 행을 게임 오브젝트에 **복사**해 붙여 주는 컴포넌트와, 그 값을 노드로 바꾸는 출력 노드를 더했다.

| 파일 | 역할 |
| --- | --- |
| `CSVParser.cs` | 컬럼 타입 문자열(`int32`, `string`, `struct` 등)에 따라 CSV 문자열 한 칸을 값으로 바꾼다 |
| `RowEntity.cs` | 표의 한 행. 컬럼 이름으로 값과 타입을 꺼낼 수 있다 |
| `TableData.cs` | 표 하나. 첫 컬럼(id)을 키로 행을 들고 있고, 특정 컬럼 값으로 행을 찾을 수 있다 |
| `DatabaseManager.cs` | CSV 파일을 `Resources`에서 읽어 `TableData`로 만들고, 화면에 디버그 창을 그린다 |
| `EntryCloner.cs` | 오브젝트가 자기만의 스탯 사본을 갖게 한다. 오브젝트 머리 위에 스탯을 그린다 |
| `Output/EntryModifierEvent.cs` | 공격자의 값으로 대상 `EntryCloner`의 스탯을 깎거나 더하는 출력 노드 |
| `Etc/GameManager.cs` | 시작할 때 스키마 CSV와 거기 적힌 모든 CSV를 연쇄로 불러온다 |
| `Resources/data/TestData - *.csv` | 테스트 데이터 4개 |

이 계층은 5e073b03("테스트데이터 추가 및 메니저베이스 안정")에서 처음 들어왔고, 636bc697("복사값과 참조값을 선택가능하도록 변경")에서 크게 다시 쓰였으며, 1e254931("인풋드리거, 레이케이스트")에서 `EntryModifierEvent`가 연결됐다. `GameManager`는 1094d49c에서 추가됐다.

## 왜

* 커밋 메시지가 직접 말하는 것은 "복사값과 참조값을 선택 가능하도록 변경"이다. 그 둘째 줄에는 "오류: 데이터베이스 디버깅파싱 오류있음"이라는 메모도 있다.
* 5e073b03 시점의 `EntryCloner`는 행의 모든 컬럼을 그대로 복사하기만 했다. `Class` 컬럼이 `ref` 타입이라 값은 "전사" 같은 ID 문자열이었다. 636bc697은 `Character` 테이블의 `Class` 컬럼 타입을 `struct`로 바꿔, 이름이 같은 `Class` 테이블의 행을 찾아 그 컬럼(HP, Atk, Range)을 오브젝트 스탯으로 **펼쳐 복사**한다. 이전 `ref` 버전 파일은 `TestData - Character.class.csv`로 남았다.
* 오브젝트마다 HP를 따로 깎아야 하므로 표를 직접 수정하면 안 되고 사본이 필요하다. 이것이 `EntryCloner`가 `_runtimeStats`라는 별도 딕셔너리를 두는 이유로 읽힌다.
* 636bc697은 `CSVParser`·`RowEntity`·`TableData`를 줄여 썼다. 이전 버전에 있던 파싱 실패 시 기본값 반환, 오류 로그, 행을 못 찾을 때의 경고가 사라졌다. 코드가 단순해진 대신 방어가 줄었다.

## 핵심 코드

### 데이터 형식

CSV는 첫 줄이 컬럼 이름, 둘째 줄이 컬럼 타입, 셋째 줄부터 데이터다. 첫 컬럼이 행의 키다.

{% code title="Resources/data/TestData - Schema.csv, Class.csv, Character.csv" %}
```csv
id,TableName,Path,Description
int64,string,string,string
1,Class,data/TestData - Class,직업별 기본 스탯 정의 테이블
2,Character,data/TestData - Character,게임 내 배치되는 캐릭터 정보 테이블

id,Name,HP,Atk,Range
int64,string,int32,int32,double
1,전사,1000,50,1.5
2,마법사,400,120,8
3,궁수,600,80,12

id,Name,Class,Level
int64,string,struct,int32
1,아서,전사,1
2,멀린,마법사,2
3,엘프,궁수,3
```
{% endcode %}

* `Schema` 표는 "어떤 표를 어느 경로에서 읽을지"를 담은 목차다. `Path`는 `Resources` 폴더 기준이며 확장자를 뺀다.
* `Character` 표의 `Class` 컬럼 타입이 `struct`다. 값 `전사`는 `Class` 표에서 id 또는 `Name`이 같은 행을 가리킨다.
* 위 CSV 세 개는 원래 별도 파일이며, 한 블록에 보이도록 빈 줄로 구분해 옮겼다.

### 불러오기

{% code title="CustumData/DatabaseManager.cs (일부)" %}
```csharp
public void LoadTableFromPath(string tableName, string path)
{
    TextAsset csvFile = Resources.Load<TextAsset>(path);
    if (csvFile == null) { Debug.LogError($"[DatabaseManager] 파일을 찾을 수 없습니다: {path}"); return; }

    string[] lines = csvFile.text.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);
    if (lines.Length < 3) return;

    string[] headers = lines[0].Trim().Split(',');
    string[] types = lines[1].Trim().Split(',');

    TableData newTable = new TableData();
    for (int i = 2; i < lines.Length; i++)
    {
        string[] values = lines[i].Trim().Split(',');
        if (values.Length < headers.Length) continue;

        RowEntity row = new RowEntity();
        for (int j = 0; j < headers.Length; j++)
        {
            object parsedValue = CSVParser.ParseValue(types[j], values[j]);
            row.SetField(headers[j], parsedValue, types[j]);
        }
        newTable.AddRow(values[0], row);
    }
    _tables[tableName] = newTable;
}
```
{% endcode %}

* `Resources.Load<TextAsset>`: `.csv`는 Unity에서 텍스트 에셋으로 읽힌다. 경로는 `Resources` 기준, 확장자 없음.
* `Split(',')`: 쉼표로만 쪼갠다. 값 안에 쉼표가 있거나 따옴표로 감싼 칸은 처리하지 못한다.
* `row.SetField(headers[j], parsedValue, types[j])`: 값과 **타입 이름을 같이 저장**한다. 636bc697의 "핵심 변경 사항"이라고 소스 주석이 적은 부분이며, `EntryCloner`가 `struct` 컬럼을 알아보는 근거가 된다.
* `newTable.AddRow(values[0], row)`: 첫 칸 문자열을 행 키로 쓴다.

### 오브젝트에 복사하기

{% code title="CustumData/EntryCloner.cs (일부)" %}
```csharp
public string targetTable = "Character";
public string targetId;
public bool autoInit = true;

public void InitFromDB(string tableName, string id)
{
    var db = GameManager.instance.DatabaseManager;
    var row = db.GetTable(tableName)?.GetRow(id);
    if (row == null) return;

    _runtimeStats.Clear();
    foreach (var col in row.GetColumns())
    {
        string type = row.GetColumnType(col);
        object val = row.Get<object>(col);

        if (type == "struct")
        {
            var subTable = db.GetTable(col);               // 컬럼 이름 = 하위 표 이름
            string searchVal = val.ToString();
            RowEntity subRow = subTable.GetRow(searchVal) ?? subTable.FindRowByColumn("Name", searchVal);
            if (subRow != null)
                foreach (var subCol in subRow.GetColumns())
                    _runtimeStats[subCol] = subRow.Get<object>(subCol);   // 하위 행을 펼쳐서 복사
        }
        else _runtimeStats[col] = val;
    }
}
public T GetStat<T>(string key) { /* _runtimeStats에서 꺼내 Convert.ChangeType */ }
public void SetStat(string key, object val) { if (_runtimeStats.ContainsKey(key)) _runtimeStats[key] = val; }
```
{% endcode %}

* `autoInit`과 `targetId`: `Start()`에서 `targetId`가 비어 있지 않으면 자동으로 `InitFromDB`를 부른다. 샘플 프리팹 `PlayerBlue`는 `Character`의 id 1(아서, 전사), `PlayerAI`는 id 2(멀린, 마법사)로 설정돼 있다.
* `type == "struct"`: **복사값 모드**다. 컬럼 이름(`Class`)으로 하위 표를 찾고, 값(`전사`)으로 id 또는 `Name`이 같은 행을 찾아 그 컬럼 전부를 `_runtimeStats`에 넣는다. 결과적으로 `Id`, `Name`, `Level`에 `HP`, `Atk`, `Range`가 합쳐진 스탯 표가 오브젝트마다 생긴다. 하위 행의 `id`, `Name`이 상위 행의 같은 이름 값을 덮어쓰는 점도 코드에서 읽힌다.
* `GetStat`/`SetStat`: 외부 노드가 값을 읽고 쓰는 창구다. `SetStat`은 **이미 있는 키만** 갱신한다.
* `OnGUI`(발췌 생략): `_runtimeStats`를 카메라 화면 좌표로 바꿔 오브젝트 머리 위에 `이름: 값` 목록으로 그린다. `GameManager.instance.MainRenderCamera`를 쓴다.

### 값을 바꾸는 출력 노드

{% code title="Output/EntryModifierEvent.cs (일부)" %}
```csharp
[SerializeField] private EntryCloner attackerCloner;
[SerializeField] private ProcessBase targetSource;
[SerializeField] private string statKey = "HP";
[SerializeField] private string valueSourceKey = "Atk";
[SerializeField] private bool isSubtraction = true;
[SerializeField] private bool destroyOnZeroHP = true;

public override void Execute()
{
    GameObject target = null;
    if (targetSource is RaycastTrigger raycastTrigger) target = raycastTrigger.GetTarget();
    else if (targetSource is Trigger trigger) target = trigger.GetTarget();
    if (target == null) return;

    EntryCloner targetCloner = target.GetComponent<EntryCloner>();
    if (targetCloner == null) return;

    int modifierValue = constantValue;
    if (attackerCloner == null) attackerCloner = GetComponent<EntryCloner>();
    if (attackerCloner != null && !string.IsNullOrEmpty(valueSourceKey))
        modifierValue = attackerCloner.GetStat<int>(valueSourceKey);

    int currentValue = targetCloner.GetStat<int>(statKey);
    int nextValue = isSubtraction ? (currentValue - modifierValue) : (currentValue + modifierValue);
    if (statKey == "HP") nextValue = Mathf.Max(0, nextValue);
    targetCloner.SetStat(statKey, nextValue);

    if (statKey == "HP" && nextValue <= 0 && destroyOnZeroHP) Destroy(target);
    IsOn = true;
}
```
{% endcode %}

* `targetSource`: 대상을 "누구로 할지"를 다른 노드에게 묻는다. `RaycastTrigger`(조준한 대상)나 `Trigger`(영역에 들어온 대상)의 `GetTarget()`을 받는다. 두 클래스 외의 노드를 넣으면 대상이 `null`이라 아무 일도 하지 않는다.
* `attackerCloner`: 공격자 값의 출처다. 비워 두면 같은 오브젝트의 `EntryCloner`를 쓴다. `valueSourceKey`가 비어 있을 때만 `constantValue`를 쓰는 구조다.
* `GetStat<int>("Atk")`로 공격력을 읽어 대상의 `HP`에서 빼고, 0 아래로는 내려가지 않게 하며, 0이 되면 대상 오브젝트를 `Destroy`한다.

### 연쇄 로드

`GameManager.ReloadAllData()`는 `DataTable`이라는 이름으로 `data/TestData - Schema`를 먼저 읽고, 스키마의 각 행에서 `TableName`과 `Path`를 꺼내 나머지 표를 같은 방식으로 읽는다. 성공 개수와 걸린 시간(`Stopwatch`)을 로그로 남긴다. `ManagerBase`를 상속하며 `Awake`에서 `DatabaseManager` 컴포넌트를 붙이고 곧바로 데이터를 불러온다([etc-gameplay.md](etc-gameplay.md)).

## 따라 만들기

완성되는 것은 "마우스 왼쪽 버튼을 누르면 플레이어가 바라보는 방향의 대상 HP를 공격자의 Atk만큼 깎는" 구성이다. 샘플 프리팹 `PlayerBlue`가 이 구성으로 돼 있다. 노드 기반이라 원본 GOS의 `ProcessBase`, `ProcessData`, `Conditional`이 먼저 필요하다([../gos/README.md](../gos/README.md)).

1. `Assets/Resources/data/`에 세 CSV를 만든다. 위 형식 그대로 쓴다(둘째 줄이 타입). 확인 방법: Unity가 세 파일을 텍스트 에셋으로 인식한다(인스펙터에 텍스트 내용이 보인다).
2. `RowEntity`, `TableData`, `CSVParser`를 작성한다. `RowEntity`는 `Dictionary<string, object>` 두 개(값, 타입)를 가지면 된다. 확인 방법: 에디터 테스트 스크립트에서 `CSVParser.ParseValue("int32", "50")`이 정수 50을 돌려준다.
3. `DatabaseManager.LoadTableFromPath`를 작성한다. 확인 방법: 씬의 임시 `MonoBehaviour`에서 `LoadTableFromPath("Class", "data/TestData - Class")`를 부른 뒤 `GetTable("Class").GetRow("1").Get<string>("Name")`이 `전사`를 돌려준다.
4. `ManagerBase<T>`(싱글톤)를 상속한 `GameManager`를 만들고 `Awake`에서 `Schema`를 읽은 다음 목록의 표를 연쇄로 읽게 한다. 확인 방법: 플레이하면 콘솔에 "로드 프로세스 종료. (성공: 2/2 ...)"류 로그가 나온다. 씬에 `GameManager`가 없어도 `GameManager.instance`를 처음 부르는 순간 자동으로 만들어진다(`ManagerBase`의 동작).
5. `EntryCloner`를 작성해 `PlayerBlue`(id 1), 적(id 2)에 붙인다. `targetTable`은 `Character`, `autoInit`은 켠다. 확인 방법: 플레이하면 두 오브젝트 머리 위에 `id, Name, Level, HP, Atk, Range`가 보인다. 아서는 `HP: 1000`, 멀린은 `HP: 400`이어야 한다. `Name`은 하위 행이 덮어써서 직업 이름(전사, 마법사)으로 보인다.
6. `RaycastTrigger`, `Conditional`, `EntryModifierEvent`를 같은 오브젝트에 붙이고 연결한다([new-nodes.md](new-nodes.md)). `Conditional`의 `inputData`는 `RaycastTrigger`, `outputData`는 `EntryModifierEvent`로 두고 `isLoop`를 켠다(샘플 프리팹도 켜져 있다). `EntryModifierEvent`의 `targetSource`에는 `RaycastTrigger`를 넣는다. `isLoop`를 켜는 이유는 `RaycastTrigger`가 명중하면 `IsOn`이 `true`로 남아, `Conditional`이 입력을 되돌려 놓지 않으면 두 번째 클릭부터 다시 실행되지 않기 때문이다(코드 읽기).
7. `InputEvent`(키는 마우스 왼쪽 버튼)를 붙이고 `outputs`에 `RaycastTrigger`를 넣어, 클릭이 `RaycastTrigger.Execute`를 부르게 한다. 확인 방법: 플레이어가 멀린을 정면으로 바라보게 두고 클릭할 때마다 머리 위 `HP`가 400, 350, 300... 으로 줄어들고 0이 되면 오브젝트가 사라진다.
8. 복사값과 참조값의 차이를 확인해 본다. `Character`의 `Class` 컬럼 타입을 `struct`에서 `ref`로 바꾸면 어떻게 되는지 7단계를 다시 해 본다. 아래 "한계"를 먼저 읽고 예상해 본 뒤 실행한다.

## 한계·주의

* **`ref` 모드는 반쪽이다.** `CSVParser`는 `ref`를 문자열 ID로 그대로 들고 있을 뿐이고, `EntryCloner`는 `struct`만 특별 처리한다. `ref` 컬럼은 `else` 가지에서 문자열 그대로 `_runtimeStats`에 들어가므로 HP, Atk가 생기지 않고, 따라서 `EntryModifierEvent`가 읽을 값이 없다. "참조값 선택"이 완성된 기능인지는 **확인 필요**다. `TestData - Character.class.csv`도 `Schema`에 등록돼 있지 않아 로드되지 않는다.
* 커밋 메시지가 직접 "데이터베이스 디버깅파싱 오류있음"이라고 적었다. 어떤 오류인지는 적혀 있지 않다. 코드에서 의심되는 곳은 `CSVParser`가 빈 칸을 `null`로 돌려주는 부분이다. `EntryCloner`의 `val.ToString()`은 `struct` 컬럼이 비어 있으면 `NullReferenceException`이 난다(코드 읽기, unverified).
* `DatabaseManager`의 디버그 창은 `#if UNITY_EDITOR || DEVELOPMENT_BUILD` 안에서 `UnityEditor.EditorStyles.miniLabel`을 쓴다. `DEVELOPMENT_BUILD`는 에디터 밖 플레이어 빌드에서도 켜지므로, 개발용 빌드에서는 `UnityEditor`를 찾지 못해 컴파일 오류가 날 것으로 보인다(**확인 필요**, 빌드하지 않았다). 에디터 안에서는 문제없고 레포의 `unity_build.log`도 에디터 컴파일이다.
* CSV 파서는 따옴표·쉼표 이스케이프, 영문 외 숫자 형식(`float.Parse`의 문화권 의존)을 처리하지 않는다. 한국어 환경에서는 대체로 문제가 없어 보이나 소수점 표기가 다른 환경에서는 달라질 수 있다.
* `GameManager`가 씬에 없으면 `GameManager.instance`가 자동 생성한다. 이때 `DatabaseManager`도 함께 붙고 즉시 CSV를 읽는다. 이 레포의 씬·프리팹에서 `GameManager` 컴포넌트가 직접 배치된 곳은 스크립트 GUID 검색으로 찾지 못했다.
* `EntryModifierEvent`는 `Trigger`와 `RaycastTrigger`만 대상 출처로 인식한다. 새 입력 노드를 만들면 이 `if`에 직접 추가해야 한다.
* 테스트 CSV는 `Assets/Resources/data`와 `Assets/GOS/Resources/data` 두 곳에 같은 내용으로 있다([changes-overview.md](changes-overview.md)).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] "복사값"과 "참조값"의 차이를 이 레포의 캐릭터와 직업(Class) 예로 설명해 보자. 오브젝트마다 HP를 따로 깎아야 할 때 어느 쪽이 필요한가?
- [ ] 데이터를 코드에 박지 않고 CSV로 빼 두면 기획자와 개발자의 일이 어떻게 달라지는가? 경험이 있다면 적어 보자.
- [ ] `Split(',')`로 CSV를 읽을 때 생길 수 있는 문제를 두 가지 이상 떠올려 보자.
