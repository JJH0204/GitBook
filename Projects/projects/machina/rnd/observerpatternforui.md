# UI 옵서버 패턴 (Observer)

public class DialogEvent { public string Speaker; public string Text; public int Priority; // 0=높음, 10=낮음 등 public float AutoCloseSec; }

public interface IDialogObserver { void OnDialogEvent(DialogEvent e); }

public class DialogEventChannel { private readonly List \_observers = new();

```
public void Subscribe(IDialogObserver obs)
{
    if (!_observers.Contains(obs)) _observers.Add(obs);
}

public void Unsubscribe(IDialogObserver obs) => _observers.Remove(obs);

public void Publish(DialogEvent e)
{
    // snapshot 후 순회(중간 구독/해제 안전)
    var snapshot = _observers.ToArray();
    foreach (var obs in snapshot) obs.OnDialogEvent(e);
}
```

}
