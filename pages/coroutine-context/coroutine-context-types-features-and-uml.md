## CoroutineContext 의 종류, 특징, UML

## 참고

- [Coroutine context and dispatchers](https://kotlinlang.org/docs/coroutine-context-and-dispatchers.html)
- [CoroutenContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/)
- [Element](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/-element/), [EmptyCoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-empty-coroutine-context/), [CoroutineContextImpl.kt](https://github.com/JetBrains/kotlin/blob/master/libraries/stdlib/src/kotlin/coroutines/CoroutineContextImpl.kt)
- [AbstractCoroutineContextElement](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-abstract-coroutine-context-element/) 
-  [CoroutineDispatcher](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-dispatcher/)

<br/>



## CoroutineContext Interface

`kotlin-coroutines-core` 라이브러리 내에 정의된 CoroutineContext 타입은 interface 로 정의되어 있습니다. 

구체적인 구현부는 `// ...` 으로 생략했고 주석은 모두 지워두었습니다. 실제 코드는 IDE 에서 직접 열어보시거나 [github.com/JetBrains/kotlin/.../CoroutineContext.kt](https://github.com/JetBrains/kotlin/blob/master/libraries/stdlib/src/kotlin/coroutines/CoroutineContext.kt) 를 참고해주시기 바랍니다.<br/>

```kotlin
@SinceKotlin("1.3")
public interface CoroutineContext {
    public operator fun <E : Element> get(key: Key<E>): E?
    public fun <R> fold(initial: R, operation: (R, Element) -> R): R
    public operator fun plus(context: CoroutineContext): CoroutineContext =
        if (context === EmptyCoroutineContext) this 
        else 
    	// ...
    
    public fun minusKey(key: Key<*>): CoroutineContext
    public interface Key<E : Element>
    public interface Element : CoroutineContext {
        public val key: Key<*>
        public override operator fun <E : Element> get(key: Key<E>): E? =
            if (this.key == key) this as E else null

        public override fun <R> fold(initial: R, operation: (R, Element) -> R): R =
            operation(initial, this)

        public override fun minusKey(key: Key<*>): CoroutineContext =
            if (this.key == key) EmptyCoroutineContext else this
    }
}
```

<br/>

이렇게 interface 로 선언해두었기 때문에 CoroutineContext 를 implements 하는 각각의 구체 클래스들은 CoroutineContext 타입으로 추상화가 가능합니다. 일반적으로 CoroutineContext 타입을 직접 바로 사용하지는 않습니다. CoroutineContext interface 를 extends 하는 EmptyCoroutineContext, Element, CombinedContext interface 를 implements 해서 사용합니다.<br/>

EmptyCoroutineContext, Element, CombinedContext interface 들은 모두 하나만 존재하는 존재인지, 여러개의 요소들을 표현한는 존재인지 등에 따라서 용도별로 내부 구현이 모두 명확하게 다르게 구현되어있습니다.<br/>

<br/>



## EmptyCoroutineContext, Element, CombinedContext, Key

[CoroutenContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/) 타입은 바로 사용되지는 않고 크게 3 종류로 나누서 [EmptyCoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-empty-coroutine-context/), [Element](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/-element/), CombinedContext 타입으로 사용됩니다. 각각의 역할은 아래와 같습니다.

- [EmptyCoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-empty-coroutine-context/)
  - EmptyCoroutineContext 는 `kotlin.coroutines` 패키지 내의 [CoroutineContextImpl.kt](https://github.com/JetBrains/kotlin/blob/master/libraries/stdlib/src/kotlin/coroutines/CoroutineContextImpl.kt) 파일에 정의되어 있습니다.  
  - EmtpyCoroutineContext 는 CoroutineContext interface를 implements 하는 구체 object 입니다. (클래스가 아닌 object 타입입니다)
  - Element 를 포함하지 않는 비어있는 CoroutineContext 를 표현하는 구체타입입니다.
  - Optional.empty, Mono.empty 처럼 비어있는 객체를 표현할 때 사용합니다.
- [Element](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/-element/)
  - Element 는 CoroutineContext interface 내에 선언되어 있는 interface 입니다. 정확하게는 CoroutineContext interface 내부에 존재하므로 CoroutineContext.Element 로 표시됩니다.
  - Element 는 CoroutineContext interface 를 extends 하고 있기에 CoroutineContext 의 기능들을 확장하고 있습니다.
  - Element 는 Element 가 하나인 상태를 의미합니다. reactor 의 Mono 처럼 하나만 존재하는 Element 를 의미합니다.
  - 잘 알려져있는 Element 구현체 또는 타입으로는 CoroutineName, CoroutineDispatcher, CoroutineExceptionHandler, Job, ThreadContextElement 가 있습니다. 
  - 코틀린 라이브러리에서 많이 보이는 [AbstractCoroutineContextElement](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-abstract-coroutine-context-element/) 클래스는 Element 를 implements 한 abstract 클래스입니다.  
  - 잘 알려져있는 [CoroutineDispatcher](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-dispatcher/) 클래스는 [AbstractCoroutineContextElement](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-abstract-coroutine-context-element/) 라고 하는 Element 타입을 extends 한 클래스입니다.
  - 코틀린의 Job interface 역시 Element interface 를 extends 하고 있습니다.
- CombinedContext (참고 : [CoroutineContextImpl.kt](https://github.com/JetBrains/kotlin/blob/master/libraries/stdlib/src/kotlin/coroutines/CoroutineContextImpl.kt) )
  - `kotlin.coroutines` 패키지 내의 [CoroutineContextImpl.kt](https://github.com/JetBrains/kotlin/blob/master/libraries/stdlib/src/kotlin/coroutines/CoroutineContextImpl.kt) 파일에 정의되어 있는 internal 클래스입니다.
  - Element 를 두 개 이상 담을 때 사용하는 타입입니다.
  - 트리 구조를 통해 left 에는 CombinedContext, right 에는 Element 를 두는데 가장 마지막 CombinedContext 의 left 에는 Element 가 위치하게 됩니다. CombinedContext 의 자료구조에 대한 설명은 문서의 하단에 자세히 정리합니다.

<br/>



이렇게 CoroutineContext interface, CoroutineContextImpl.kt 등에 정의된 EmptyCoroutineContext, Element, CombinedContext 는 모두 연산자 오버로딩으로 plus, minusKey, get 등이 정의되어 있기 때문에 +, -기호로 plus, minusKey 연산을 수행할 수 있고 `[key]` 를 통해서 get 연산을 수행할 수 있습니다.<br/>

<br/>



위에서 살펴본 3종류의 타입들과는 다르게 [Key](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/-key.html) 라는 타입이 있습니다. Key 역시 interface 로 선언된 타입입니다. 이 Key 는 Element 를 구별하기 위해 사용되며 CombinedContext 에서 사용됩니다.<br/>

<br/>



## CoroutineContext 의 연산자 오버로딩





## CoroutineContext 자료구조



## 대표적인 CoroutineContext 의 종류들

UML 과 함께 정리



