# memset()

\#c #Coding #개발

**메시지 원문**

> Call to function 'memset' is insecure as it does not provide security checks introduced in the C11 standard. Replace with analogous functions that support length arguments or provides boundary checks such as 'memset\_s' in case of C11

**메시지 번역**

> 함수 'memset'에 대한 호출은 C11 표준에 도입된 보안 검사를 제공하지 않으므로 안전하지 않습니다. C11의 경우 length 인수를 지원하거나 'memset\_s'와 같은 경계 검사를 제공하는 유사한 함수로 대체합니다

**해결 방법**

* memset을 대체할 함수를 찾아야 한다. -> 찾지 못했다.

<details>

<summary>코드: initList</summary>

```c
int initList(polyList *_pList_)
{
	if (_pList_ == NULL)
	{
		printf("Error attempting to initialize unallocated memory: initList()\n");
		return -1;
	}
	_pList_->nCurrentCount = 0;
	initNode(&(_pList_->headerNode));
	return 0;
}
```

</details>

<details>

<summary>코드: initNode</summary>

```c
int initNode(node *_pNode_)
{
    if (_pNode_ == NULL)
    {
        printf("Error attempting to initialize unallocated memory: initNode()\n");
        return -1;
    }
    _pNode_->pNext = NULL;
    _pNode_->tData.coefficient = 0;
    _pNode_->tData.degree = 0;
    return 0;
}
```

</details>
