# function arguments by reference

This page demonstrates passing function arguments by reference in C with several examples.

{% stepper %}
{% step %}
### EX1

Passing by value (no effect on caller's variable):

```c
/*EX1*/
void addone(int n) {
    // n is local variable which only exists within the function scope
    n++; // therefore incrementing it has no effect
}

int n;
printf("Before: %d\n", n);
addone(n);
printf("After: %d\n", n);
```
{% endstep %}

{% step %}
### EX2

Passing a pointer so the function can modify the caller's variable:

```c
/*EX2*/
void addone(int *n) {
    // n is a pointer here which points to a memory-address outside the function scope
    (*n)++; // this will effectively increment the value of n
}

int n;
printf("Before: %d\n", n);
addone(&n);
printf("After: %d\n", n);
```
{% endstep %}

{% step %}
### EX3

Modifying fields of a struct via pointer:

```c
/*EX3*/
void move(point * p) {
    (*p).x++;   // p->x++;
    (*p).y++;   // p->y++;
}
```
{% endstep %}
{% endstepper %}

## Exercise

Given the `person` struct and a `birthday` function that should increment the person's age by reference.

```c
typedef struct {
  char * name;
  int age;
} person;

/* function declaration */
void birthday(person * p);

/* write your function here */
void birthday(person * p)
{
    p -> age++;
}

int main() {
  person john;
  john.name = "John";
  john.age = 27;

  printf("%s is %d years old.\n", john.name, john.age);
  birthday(&john);
  printf("Happy birthday! %s is now %d years old.\n", john.name, john.age);

  return 0;
}
```

This program demonstrates modifying a struct's field by passing a pointer to the struct into the function.
