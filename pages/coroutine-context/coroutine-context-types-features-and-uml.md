## CoroutineContext 의 종류, 특징, UML

## 참고

- [Coroutine context and dispatchers](https://kotlinlang.org/docs/coroutine-context-and-dispatchers.html)
- [CoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/)
- [Element](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/-element/), [EmptyCoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-empty-coroutine-context/), [CoroutineContextImpl.kt](https://github.com/JetBrains/kotlin/blob/master/libraries/stdlib/src/kotlin/coroutines/CoroutineContextImpl.kt)
- [AbstractCoroutineContextElement](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-abstract-coroutine-context-element/) 
- [CoroutineDispatcher](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines/-coroutine-dispatcher/)

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

[CoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/) 타입은 바로 사용되지는 않고 크게 3 종류로 나누서 [EmptyCoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-empty-coroutine-context/), [Element](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/-element/), CombinedContext 타입으로 사용됩니다. 각각의 역할은 아래와 같습니다.

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

[CoroutineContext](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.coroutines/-coroutine-context/) 는 get, plus, minusKey, fold 연산을 지원합니다. CoroutineContext Interface 코드의 요약본을 살펴보면 아래와 같습니다.

- get(Key) : 특정 Key 를 갖는 Element 타입을 리턴하는 메서드입니다.
- plus(CoroutineContext) : 현재 CoroutineContext 에 다른 CoroutineContext 를 병합하는 연산을 수행하는 메서드입니다. 만약 이미 같은 Key 를 갖는 Element 가 다른 Context 등에 이미 존재하고 있다면, 그 Element 를 Update 합니다.
- minusKey(Key) : 현재 CoroutineContext 내에서 주어진 Key 에 해당하는 Element 를 제거한 후 CoroutineContext 를 반환합니다.

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



이미 존재하는 CoroutineContext 에 다른 CoroutineContext 를 결합해서 사용하는 경우는 굉장히 많습니다. 이렇게 두개 이상의 CoroutineContext 를 합쳐서 여러 개의 CoroutineContext 를 갖는 자료구조는 CombinedContext 라는 타입으로 표현을 합니다. 이렇게 두개 이상의 CoroutineContext 를 갖는 자료구조는 CombinedContext 라는 타입을 통해 표현하며, CombinedContext 의 자료 구조는 트리와 같은 구조입니다. 이 CombinedContext 의 데이터 구조는 이 문서의 하단에서 정리합니다.<br/>



이 CombinedContext 자료구조는 CoroutineContext 타입을 통해서 이루어지는 것이고 CombinedContext 는 CoroutineContext 를 구체화 했기에 CoroutineContext 가 지원하는 연산자 오버로딩이 적용 되니다. 예를 들면 여러개의 CoroutineContext 가 더해지거나 빼지거나 get 을 하기 위해 연산자 오버로딩이 되어 있습니다.<br/>

이번 Step 에서는 이렇게 특정 CoroutineContext 를 더하고 ,빼고, get 을 하는 것에 대한 예제를 살펴보겠습니다.<br/>



### plus 연산

CoroutineContext 의 plus 연산은 아래와 같은 방식으로 이뤄집니다.

- EmptyCoroutineContext + Element 연산 = Element
  - Element 로 합쳐집니다. 
  - Element 와 Empty 를 더하는 연산은 Element 하나로 취급해서 CoroutineContext 1개 짜리의 조합이 된다고 생각하면 쉽습니다.
- Element + Element 연산 = CombinedContext 
  - CombinedContext 가 됩니다. 
  - Element 타입 2개가 합쳐진 것은 CoroutineContext 타입 2개 이상의 타입이 되는 것이기 때문입니다.
- Element + Element 연산 = Element 
  - Element + Element 를 할 때 Element 가 모두 같은 CoroutineContext Key 를 가지면 하나의 Element 로 합쳐진다고 간주해서 결과는 Element 가 됩니다.
- CombinedContext + Element 연산 = CombinedContext 
  - CombinedContext 가 됩니다.
  - 이미 두 개 이상의 요소에 하나를 더 append 하기에 CombinedContext 가 됩니다.
  - 두 개 이상의 CoroutineContext 에 Element 를 합치는 것은 이미 존재하는 2개 이상의 CoroutineContext에 1개의 CoroutineContext를 append 하는 연산으로 생각하면 쉽습니다.

<br/>



아래는 예제 코드입니다.

```kotlin
package io.chagchagchag.demo.kotlin_coroutine.coroutine_context

import io.chagchagchag.demo.kotlin_coroutine.helper.logger
import kotlinx.coroutines.CoroutineName
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlin.coroutines.EmptyCoroutineContext

fun main(){
  val log = logger()
  // (1)
  val emptyContext = EmptyCoroutineContext // object 타입이기에 생성자를 호출하지 않아도 바로 대입이 됩니다.
  log.info("emptyContext = $emptyContext")

  // (2)
  val element1 = CoroutineName("배고파요")
  val mergedContext1 = emptyContext + element1
  log.info("mergedContext1 = $mergedContext1, 클래스 = ${mergedContext1.javaClass.simpleName}")

  // (3)
  val element2 = CoroutineName("한입만")
  val mergedContext2 = mergedContext1 + element2
  log.info("mergedContext2 = $mergedContext2, 클래스 = ${mergedContext2.javaClass.simpleName}")

  // (4)
  val element3 = Dispatchers.IO
  val mergedContext3 = mergedContext2 + element3
  log.info("mergedContext3 = $mergedContext3, 클래스 = ${mergedContext3.javaClass.simpleName}")

  // (5)
  val element4 = Job()
  val mergedContext4 = mergedContext3 + element4
  log.info("mergedContext4 = $mergedContext4, class = ${mergedContext4.javaClass.simpleName}")
}
```



(1) 

- EmptyCoroutineContext 를 출력해봅니다. 
- EmptyCoroutineContext 는 object 타입이기에 생성자를 호출하지 않아도 바로 대입이 됩니다.

(2)

- EmptyCoroutineContext 와 Element 를 더하고 있습니다.
- Empty + Element 이므로 결과는 Element 가 됩니다.
- 출력결과를 보면 CoroutineName 으로 출력됩니다. CoroutineName 은 AbstractCoroutineContextElement 타입인데, Element 타입으로 추상화가 가능합니다.

(3)

- Element + Element 를 수행하지만 같은 CoroutineContext Key 를 가지고 있습니다. 따라서 같은 CoroutineContext 에 합쳐지는 것이 되기에 결과는 Element 가 됩니다.
- 출력결과를 보면 CoroutineName 으로 출력됩니다. CoroutineName 은 AbstractCoroutineContextElement 타입인데, Element 타입으로 추상화가 가능합니다.

(4)

- Element + Element 를 수행하게 되므로 결과는 CombinedContext 가 됩니다.
- 출력결과를 보면 CombinedContext 가 출력됩니다.
- CoroutineDispatcher 는 AbstractCoroutineContextElement 타이기에 Element 타입으로 추상화가 가능합니다.

(5)

- CombinedContext + Element 를 수행하므로 결과는 CombinedContext 가 됩니다.
- 출력결과를 보면 CombinedContext 가 출력됩니다.
- Job() 은 Job.kt 에 정의된 함수이고 실제로는 JobSupport.kt 내에 정의된 JobImpl 이라는 internal class 타입입니다. 이 JobImpl class 역시 Job 타입인데, Job 은 interface 타입이고, CoroutineContext.Element 를 extends 하고 있습니다. 따라서 Element 로 추상화가 가능합니다.



```kotlin
01:47:33.264 [main] INFO io...LoggingObject -- emptyContext = EmptyCoroutineContext
01:47:33.280 [main] INFO io...LoggingObject -- mergedContext1 = CoroutineName(배고파요), 클래스 = CoroutineName
01:47:33.285 [main] INFO io...LoggingObject -- mergedContext2 = CoroutineName(한입만), 클래스 = CoroutineName
01:47:33.329 [main] INFO io...LoggingObject -- mergedContext3 = [CoroutineName(한입만), Dispatchers.IO], 클래스 = CombinedContext
01:47:33.351 [main] INFO io...LoggingObject -- mergedContext4 = [CoroutineName(한입만), JobImpl{Active}@5442a311, Dispatchers.IO], class = CombinedContext
```

<br/>



### minusKey 연산

CombinedContext 의 minusKey 연산은 아래와 같은 방식으로 이뤄집니다. 요소를 삭제할 때에는 key 를 통해 해당 Element 가 있는지 조회해서 삭제합니다.

- CombinedContext - Element = CombinedContext
  - CombinedContext 에서 Element 를 하나 빼도 2개 이상인 경우에는 결과가 CombinedContext 가 됩니다.
- CombinedContext - Element = Element
  - CombinedContext 에서 Element를 하나 빼서 CoroutineContext가 1개가 되었을 경우에는  Element 가 됩니다.
- Element - Element = EmptyCoroutineContext
  - CoroutineContext 1개에서 CoroutineElement 1개를 빼므로 0개가 되어서 EmptyCoroutineContext 가 됩니다.



아래는 예제 코드입니다.

```kotlin
package io.chagchagchag.demo.kotlin_coroutine.coroutine_context

import io.chagchagchag.demo.kotlin_coroutine.helper.logger
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.CoroutineName
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job

@OptIn(ExperimentalStdlibApi::class)
fun main(){
  val log = logger()
  // (1)
  val context1 = CoroutineName("짬뽕") + Dispatchers.IO + Job()
  log.info("context1 = $context1, 클래스 = ${context1.javaClass.simpleName}")
  // (2)
  val minus1 = context1.minusKey(Job)
  log.info("minus1 = $minus1, 클래스 = ${minus1.javaClass.simpleName}")
  // (3)
  val minus2 = minus1.minusKey(Job)
  log.info("minus2 = $minus2, 클래스 = ${minus2.javaClass.simpleName}")
  // (4)
  val minus3 = minus2.minusKey(CoroutineDispatcher)
  log.info("minus3 = $minus3, 클래스 = ${minus3.javaClass.simpleName}")
  // (5)
  val minus4 = minus3.minusKey(CoroutineName)
  log.info("minus4 = $minus4, 클래스 = ${minus4.javaClass.simpleName}")
}
```

<br/>



(1)

- 3 종류의 CoroutineContext 를 더해서 3개의 CoroutineContext 가 존재하는 CombinedContext 를 만듭니다.
- 따라서 결과값은 CombinedContext 가 출력됩니다.

(2)

- (1) 에서 추가한 Job 타입의 CoroutineContext 를 제거합니다. 출력결과를 보면 Job 타입의 CoroutineContext 가 제거되고 Dispatchers.IO, CoroutineName(짬뽕) 만 남습니다.
- 코드와 출력결과를 통해 minusKey()의 인자에는 코틀린 클래스 (KClass) 타입을 넘기면 된다는 사실을 알수 있습니다.

(3)

- (2) 에서 했던 연산을 한번 더 해서 똑같이 Job 타입을 빼려 할 때 어떻게 되는지를 확인합니다. 
- Job 타입은 이제 더 이상 CoroutineContext 내에 존재하지 않기에 출력결과는 달라지지 않습니다.

(4)

- CoroutineDispatcher 를 뺍니다. minusKey 를 통해 CoroutineContext 에 CoroutineDispatcher 타입이 있는지 검색한 후 CoroutineDispatcher 타입이 있다면 해당 타입을 CoroutineContext 에서 삭제합니다.
- 출력결과는 CoroutineDispatcher 가 제거된 후의 결과값이 출력됩니다.

(5)

- 마지막으로 남은 CoroutineName 객체를 지웁니다.
- minusKey 함수에 CoroutineName 클래스 타입을 전달해줬고, 정상적으로 CoroutineName 객체가 삭제되었습니다.

<br/>



출력결과

```plain
02:49:07.584 [main] INFO io...LoggingObject -- context1 = [CoroutineName(짬뽕), JobImpl{Active}@5e3a8624, Dispatchers.IO], 클래스 = CombinedContext
02:49:07.587 [main] INFO io...LoggingObject -- minus1 = [CoroutineName(짬뽕), Dispatchers.IO], 클래스 = CombinedContext
02:49:07.587 [main] INFO io...LoggingObject -- minus2 = [CoroutineName(짬뽕), Dispatchers.IO], 클래스 = CombinedContext
02:49:07.589 [main] INFO io...LoggingObject -- minus3 = CoroutineName(짬뽕), 클래스 = CoroutineName
02:49:07.590 [main] INFO io...LoggingObject -- minus4 = EmptyCoroutineContext, 클래스 = EmptyCoroutineContext
```

<br/>



### get 연산

```kotlin
```

<br/>



## CoroutineContext 자료구조



## 대표적인 CoroutineContext 의 종류들

UML 과 함께 정리



