## 一些C++的学习笔记

***
**C/C++**

从设计思想上：

c是面向过程的，c++是面向对象的

从语法上：

c++包含了多态、封装、继承的属性

c++支持范式编程，如模板类，和模板函数

c++相比c有很多安全检查，如类型转换检查


### 有符号数的存储

【补码】 正数补码与原码相同 负数补码为删除符号位，然后取反加1.

计算机以二进制的补码存储数据

![image-20201229155903216](E:\笔记\C++其他\cpp笔记.assets\image-20201229155903216.png)

从补码到原码的计算：
方式一：减1得到反码，再取反
方式二：负数补码速算：最低位(右)向高位(左)，查找到第一个1与符号位之间的所有数字按位取反的逆运算  如 10010110  11101010 = -106

------

### string和char* 

##### char*转string

```c++
string s1;

const char *pc = "a character  array";

s1 = pc;
```

##### string 转char*
```c++
const char* str = s1.c_str();
```
但s1可能被析构，内容被处理，则应该
```c++
char c[20];
strcpy(c, s1,c_str());
```

##### 基本数据类型转string
- itoa函数 (win)  // 非c/c++标准

  ```c++
  _itoa(n, ch, 10);
  ```

- std::to_string()

  ```c++
  std::string str = std::to_string(value);
  ```

- 借助stringstream， 但速度慢

  ```c++
  stringstream ss;
  string str;
  int n = 10;
  ```

- c库函数sprintf()，可以转化各种类型的数，但要提前分配内存

  ```c++
  char ch[10];
  sprintf(ch, %d, 2901);
  string str(ch, ch + strlen(ch);  //把char*转换成string，注意遇到空字符不停止拷贝
  ```

------

### 三种传参方式

```c++
function1(std::vector<std::vector<int> > vec); //传值      需要构造拷贝
function2(std::vector<std::vector<int> >& vec); //传引用   不需要构造拷贝
function3(std::vector<std::vector<int> >* vec); //传指针   不发生构造拷贝
```

#### 右值引用、移动语义和完美转发

(https://www.jianshu.com/p/d19fc8447eaa)

c++中引入了 `右值引用` 和 `移动语义` ，可以避免无谓的复制，提高程序性能。

> **左值 右值**

`C++`中所有的值都必然属于左值、右值二者之一。

**左值**是指表达式结束后依然存在的*持久化对象*，**右值**是指表达式结束时就不再存在的*临时对象*。所有的具名变量或者对象都是左值，而右值不具名。

在c++98中，引用相当于给变量取了个别名。在`c++11`中，因为增加了**右值引用(rvalue reference)**的概念，所以`c++98`中的引用都称为了**左值引用(lvalue reference)**。

```c++
int a = 10; 
int& refA = a; // refA是a的别名， 修改refA就是修改a, a是左值，左移是左值引用

int& b = 1; //编译错误! 1是右值，不能够使用左值引用
```

`c++11`中的右值引用使用的符号是`&&`，如

```c++
int&& a = 1; //实质上就是将不具名(匿名)变量取了个别名
int b = 1;
int && c = b; //编译错误！ 不能将一个左值复制给一个右值引用
class A {
  public:
    int a;
};
A getTemp()
{
    return A();
}
A && a = getTemp();   //getTemp()的返回值是右值（临时变量）
```

`getTemp()` 返回的右值本来在表达式语句结束后，其生命也就该终结了（因为是临时变量），而通过右值引用，该右值又重获新生，其生命期和右值引用变量`a`一样，只要`a`还活着，该右值临时变量将会一直存活下去。

**注意**：这里`a`的**类型**是右值引用类型(`int &&`)，但是如果从左值和右值的角度区分它，它实际上是个**左值**。因为可以对它取地址，而且它还有名字，是一个已经命名的右值。

**常量左值引用**却是个奇葩，它可以算是一个“万能”的引用类型，它可以绑定非常量左值、常量左值、右值，而且在绑定右值的时候，常量左值引用还可以像右值引用一样将右值的生命期延长，缺点是，只能读不能改。

```c++
const int & a = 1; //常量左值引用绑定 右值， 不会报错

class A {
  public:
    int a;
};
A getTemp()
{
    return A();
}
const A & a = getTemp();   //不会报错 而 A& a 会报错
```

总结一下，其中`T`是一个具体类型：

1. 左值引用， 使用 `T&`, 只能绑定**左值**
2. 右值引用， 使用 `T&&`， 只能绑定**右值**
3. 常量左值， 使用 `const T&`, 既可以绑定**左值**又可以绑定**右值**
4. 已命名的**右值引用**，编译器会认为是个**左值**
5. 编译器有返回值优化，但不要过于依赖

> **移动构造和移动赋值**

假设用c++实现一个字符串类`MyString`，`MyString`内部管理一个C语言的`char *`数组，这个时候一般都需要实现拷贝构造函数和拷贝赋值函数，因为默认的拷贝是浅拷贝，而指针这种资源不能共享，不然一个析构了，另一个也就完蛋了。

```c++
class MyString {
   MyString(const char* cstr=0) {
       if (cstr) {
          m_data = new char[strlen(cstr)+1];
          strcpy(m_data, cstr);
       }
       else {
          m_data = new char[1];
          *m_data = '\0';
       }
   }
  
   MyString(const MyString& str) {
       m_data = new char[ strlen(str.m_data) + 1 ];
       strcpy(m_data, str.m_data);
   }
  
   MyString& operator=(const MyString& str){
       if (this == &str) // 避免自我赋值!!
          return *this;

       delete[] m_data;
       m_data = new char[ strlen(str.m_data) + 1 ];
       strcpy(m_data, str.m_data);
       return *this;
   }
     ~MyString() {
       delete[] m_data;
   }

   char* get_c_str() const { return m_data; }
private:
   char* m_data;
};
```

在 `vec.push_back(MyString("hello")` 时，调用了拷贝构造函数。如果字符串本来就很长，还要构造和拷贝一遍。而`MyString("hello")`只是临时对象，拷贝完就没什么用了，造成了没有意义的资源申请和释放。可以用`c++11`新增的移动语义。

要实现移动语义就必须增加两个函数：**移动构造函数**和**移动赋值构造函数**。

```c++
// 移动构造函数
MyString(MyString&& str) noexcept 
  :m_data(str.m_data) {
    str.m_data = nullptr;    // 不再指向之前的资源，废弃掉
}

// 移动赋值函数
MyString& operator=(MyString && str) noexcept {
  if (this == &str)  // 避免自我赋值!!
    return *this;
  
  delete[] m_data;
  m_data = str.m_data;
  str.m_data = nullptr;   // 不再指向之前的资源
  return *this;
}
```

可以看到，移动构造函数与拷贝构造函数的区别是，拷贝构造的参数是`const MyString& str`，是*常量左值引用*，而移动构造的参数是`MyString&& str`，是*右值引用*，而`MyString("hello")`是个临时对象，是个右值，优先进入**移动构造函数**而不是拷贝构造函数。

而移动构造函数与拷贝构造不同，它并不是重新分配一块新的空间，将要拷贝的对象复制过来，而是"偷"了过来，将自己的指针指向别人的资源，然后将别人的指针修改为`nullptr`，这一步很重要，如果不将别人的指针修改为空，那么临时对象析构的时候就会释放掉这个资源，"偷"也白偷了。

![https://upload-images.jianshu.io/upload_images/4427263-81a47fdc9b8d9e98.png](https://upload-images.jianshu.io/upload_images/4427263-81a47fdc9b8d9e98.png)

不用奇怪为什么可以抢别人的资源，临时对象的资源不好好利用也是浪费，因为生命周期本来就是很短，在你执行完这个表达式之后，它就毁灭了，充分利用资源，才能很高效。

对于一个左值，肯定调用拷贝构造函数，但有些左值是局部变量，生命周期也很短，也可以移动而不是拷贝。`c++11`用`std::move()`方法将左值转化为右值，更方便移动语义。

```c++
    for(int i=0;i<1000;i++) {
        MyString tmp("hello");
        vecStr2.push_back(std::move(tmp)); //调用的是移动构造函数
    }
```

注意一下几点：

1. 用`str2 = std::move(str1)`，虽然将 `str1` 的资源给了 `str2`，但是 `str1` 并没有析构，只有离开自己的作用域才会析构。所以如果继续使用 `str2` 的 `m_data` 变量，可能会发生意想不到的错误。

2. 如果我们没有提供移动构造函数，只提供了拷贝构造函数，`std::move` 会失效，但不会报错。编译器找不到移动构造函数就寻找拷贝构造函数，这也是拷贝构造函数是 `const T&` 常量左值引用的原因。所以说`move`对含有资源的对象说更有意义。

> universal references （通用引用）

当右值引用和模板结合的时候，就复杂了。`T&&`并不一定表示右值引用，它可能是个左值引用又可能是个右值引用。例如：

```c++
template<typename T>
void f( T&& param){
    
}
f(10);  //10是右值
int x = 10; //
f(x); //x是左值
```

这里的`&&`是一个未定义的引用类型，称为`universal references`，它必须被初始化，它是左值引用还是右值引用却决于它的初始化，如果它被一个左值初始化，它就是一个左值引用；如果被一个右值初始化，它就是一个右值引用。

**注意**：只有当**发生自动类型推断**时（如函数模板的类型自动推导，或auto关键字），`&&`才是一个`universal references`。

> 完美转发

所谓转发，就是通过一个函数将参数继续转交给另一个函数进行处理，原参数可能是右值，可能是左值，如果**还能继续保持参数的原有特征**，那么它就是完美的。

```c++
void process(int& i){
    cout << "process(int&):" << i << endl;
}
void process(int&& i){
    cout << "process(int&&):" << i << endl;
}

void myforward(int&& i){
    cout << "myforward(int&&):" << i << endl;
    process(i);
}

int main()
{
    int a = 0;
    process(a); //a被视为左值 process(int&):0
    process(1); //1被视为右值 process(int&&):1
    process(move(a)); //强制将a由左值改为右值 process(int&&):0
    myforward(2);  //右值经过forward函数转交给process函数，却称为了一个左值，
    //原因是该右值有了名字  所以是 process(int&):2
    myforward(move(a));  // 同上，在转发的时候右值变成了左值  process(int&):0
    // forward(a) // 错误用法，右值引用不接受左值
}
```

上面的例子就是不完美转发，而c++中提供了一个`std::forward()`模板函数解决这个问题。将上面的`myforward()`函数简单改写一下：

```c++
void myforward(int&& i){
    cout << "myforward(int&&):" << i << endl;
    process(std::forward<int>(i));
}

myforward(2); // process(int&&):2
```

上面修改后还是不完美转发，`myforward()`函数能够将右值转发过去，但是并不能够转发左值，解决办法就是借助`universal references`通用引用类型和`std::forward()`模板函数共同实现完美转发。

```c++
// 这里利用了universal references，如果写T&,就不支持传入右值，而写T&&，既能支持左值，又能支持右值
template<typename T>
void perfectForward(T && t) {
    RunCode(forward<T> (t));
}
```

最后，用`emplace_back()` 替换 `push_back()` 来减小内存拷贝和移动，也是用到了 `c++11` 移动语义和完美转发。



---

### 类型转换

c语言中的强制转换主要是普通数据类型、指针的强制转换，没有类型检查，转换不安全：

(type-id) expression

type-id(expression)



除此之外，c++还使用`xxx_cast<new_type>  (expression) `  进行类型的转换。

| 转换类型操作符   | 作用                                                         |
| ---------------- | ------------------------------------------------------------ |
| const_cast       | 去掉类型的const或volatile属性                                |
| static_cast      | 无条件转换，静态类型转换                                     |
| dynamic_cast     | 有条件转换，动态类型转换，运行时检查类型安全（转换失败返回NULL） |
| reinterpret_cast | 仅重新解释类型，但没有进行二进制的转换                       |

说明：

1. static_cast 静态转换（编译时检查）

   相当于`C`中的强制转换，但不能实现普通指针数据（空指针除外）的强制转换，一般用于父类、子类指针、引用间的互相转换。

   特点是，父子之间转换不会报错，不支持类间交叉转换。不能转换掉const、volatile、或者__unaligned属性。

2. dynamic_cast 动态转换（运行时检查）

   用于类间转换，支持类间交叉转换，不能操作普通数据。

3. const_cast 常量转换

   用于修改类型的const或volatile属性，不能对非指针或非引用的变量添加或移除const。

4. reinterpret_cast 重新解释转换

   可以将任意类型转换为任意类型，非常不安全。只适合将转换后的类型值转换回到其原始类型。



-------

### const出现在不同位置的含义

```c++
const int *const method(const int *const &param) const;
  1          2            3          4             5
```

1. const int    常量整型（值不能被修改）

2. *const       常量指针（指向的对象不能被修改）

   1和2结合起来：const int *const method();

   返回指向常量整型的常量指针。

3. 同1

4. 同2

   3和4结合起来：const int *const &param

形参为指向 指向常量整型的常量指针的 引用。

##### 关于 const 其他知识点：

1. 非const变量默认为extern。要使const变量能够在其他文件中访问，必须制定它为extern。

2. const引用：指向const对象的引用。非const引用只能绑定到与该引用同类型的对象。

3. const对象的动态数组。如果存储了内置类型的const，必须初始化：

   ```c++
   const int *pci_ok = new const int [100]();
   
   const string *pcs = new const string[100];
   ```

------

### Struct 和 Union 区别

1. 在存储多个成员信息时，编译器会自动给struct第个成员分配存储空间，struct 可以存储多个成员信息，而Union每个成员会用同一个存储空间，只能存储最后一个成员的信息。
2. 都是由多个不同的数据类型成员组成，但在任何同一时刻，Union**只存放了一个**被先选中的成员，而结构体的所有成员**都存在**。
3. 对于Union的不同成员赋值，将会对其他成员重写，原来成员的值就不存在了（覆盖），而对于struct 的不同成员赋值是互不影响的。

---

### 占用的内存分布

种类：

一个由C/C++编译程序占用内存分为以下几个部分
1、**栈区**（stack）— 由编译器自动分配释放 ，存放函数参数值，局部变量值等。其操作方式类似于数据结构中栈。
2、**堆区**（heap） — 一般由程序员分配释放， 若程序员不释放，程序结束时可能由OS回收 。注意它与数据结构中堆是两回事，分配方式倒是类似于链表。
3、**全局区（静态区）**（static）—，全局变量和静态变量存储是放在一块，初始化全局变量和静态变量在一块区域， 未初始化全局变量和未初始化静态变量在相邻另一块区域。 - 程序结束后由系统释放。-->分别是data区，bbs区 
4、**文字常量区** —常量字符串就是放在这里。 程序结束后由系统释放-->coment区
5、**程序代码区**—存放函数体二进制代码。-->code(text)区

#### 堆和栈的区别

**申请：**

stack: 

由系统自动分配。例如，声明在函数中一个局部变量 int b; 系统自动在栈中为b开辟空间

在Windows下,栈是向低地址扩展数据结构(栈向下生长)，是一块连续内存区域。效率高



heap: 需要程序员自己申请，并指明大小，如 c 的 `malloc` 和 c++ 的 `new`

堆是向高地址扩展数据结构（堆向上生长），是不连续内存区域。这是由于系统是用链表来存储空闲内存地址，而链表遍历方向是由低地址向高地址。堆大小受限于计算机系统中有效的虚拟内存。由此可见，堆获得空间灵活，也比较大。速度较慢。



堆和栈区别可以用如下比喻来看出：
使用栈就象我们去饭馆里吃饭，只管点菜（发出申请）、付钱、和吃（使用），吃饱了就走，不必理会切菜、洗菜等准备工作和洗碗、刷锅等扫尾工作，他好处是快捷，但自由度小。
使用堆就象是自己动手做喜欢吃菜肴，比较麻烦，但是比较符合自己口味，而且自由度大。

---

### 智能指针

内存管理是C++中的一个常见的错误和bug来源。当多次释放动态分配的内存时，可能会导致内存损坏或者致命的运行时错误；当忘记释放动态分配的内存时，会导致内存泄露。

自己申请的指针是分配在堆上的，而对类来说，自调用的内存是分配在栈上的。

所以，我们需要智能指针来帮助我们管理动态分配的内存。其来源于一个事实：栈比堆要安全的多，因为栈上的变量离开作用域后，会自动销毁并清理。智能指针结合了栈上变量的安全性和堆上变量的灵活性。

举例：假如在函数开始new了一个对象，但中间异常抛出，程序中断，就会导致new的资源没有回收，导致内存泄露。那么这个时候可以用类来表征指针：类内存储指针，当类出了作用域之后，析构函数就一定会执行。

https://zhuanlan.zhihu.com/p/54078587?from_voters_page=true

c++是通过完美转发和右值引用进行智能指针实现的。

`C++11`标准库中含有四种智能指针：`std::auto_ptr`（不要使用）, `std::unique_ptr`, `std::shared_ptr`和 `std::weak_ptr`。下面我们逐个介绍后面三个智能指针。

`std::unique_ptr`是`std::auto_ptr`的替代品，其用于不能被多个实例共享的内存管理。这就是说，仅有一个实例拥有内存所有权。

c++14可以使用`make_unique`函数创建`unique_ptr`实例，如果不支持，你可以实现简化的版本：

```c++
// 注意：无法处理数组
template<typename T, typename ... Ts>
std::unique_ptr<T> make_unique(Ts ... args)
{
    return std::unique_ptr<T> {new T{ std::forward<Ts>(args) ... }};
}
```

可以看到`std::unique_ptr`对象可以传值给左值常量引用参数，因为这并不会改变内存所有权。

如果想改变所有权，需要转移`std::move`。

`std::unique_ptr`还有几个常用的方法： 1.  release()：返回该对象所管理的指针，同时释放其所有权； 2. reset()：析构其管理的内存，同时也可以传递进来一个新的指针对象；  3. swap()：交换所管理的对象； 4. get()：返回对象所管理的指针； 5.  get_deleter()：返回析构其管理指针的调用函数。

`std::shared_ptr`与`std::unique_ptr`类似。要创建`std::shared_ptr`对象，可以使用`make_shared()`函数（c++11支持）。`std::shared_ptr`与`std::unique_ptr`的主要区别在于前者是使用引用计数的智能指针。引用计数的智能指针可以跟踪引用同一个真实指针对象的智能指针实例的数目。这意味着，可以有多个`std::shared_ptr`实例可以指向同一块动态分配的内存，当最后一个引用对象离开其作用域时，才会释放这块内存。

`std::shared_ptr`可以实现多个对象共享同一块内存，当最后一个对象离开其作用域时，这块内存被释放。但是仍然有可能出现内存无法被释放的情况，联想一下“死锁”现象。“循环引用”现象。

这时候`std::weak_ptr`应运而生。`std::weak_ptr`可以包含由`std::shared_ptr`所管理的内存的引用。但是它仅仅是旁观者，并不是所有者。那就是`std::weak_ptr`不拥有这块内存，当然不会计数，也不会阻止`std::shared_ptr`释放其内存。但是它可以通过`lock()`方法返回一个`std::shared_ptr`对象，从而访问这块内存。

创建和析构的顺序是反的？在栈上！

---

### 继承关系

三种继承方式：

**公有继承**

- 继承的访问控制

基类的public和protected成员：访问属性在派生类中保持不变；

基类的private成员：不可直接访问。

- 访问权限

派生类中的成员函数：可以直接访问基类中的public和protected成员，但不能直接访问基类的private成员；

通过派生类的对象：只能访问public成员。

**私有继承**

- 继承的访问控制

基类的public和protected成员：都以private身份出现在派生类中；

基类的private成员：不可直接访问。

- 访问权限

派生类中的成员函数：可以直接访问基类中的public和protected成员，但不能直接访问基类的private成员；

通过派生类的对象：不能直接访问从基类继承的任何成员。

**保护继承**

- 继承的访问控制

基类的public和protected成员：都以protected身份出现在派生类中

基类的private成员：不可直接访问。

- 访问权限

派生类中的成员函数：可以直接访问基类中的public和protected成员，但不能直接访问基类的private成员；

通过派生类的对象：不能直接访问从基类继承的任何成员。

------

### 类的构造函数

对一个c++的空类，编译器会加入默认的成员函数有：

·默认构造函数和拷贝构造函数

·析构函数

·赋值函数（赋值运算符）

·取值函数
```c++
A a;   		// 调用默认构造函数
A b(a);  	// 拷贝构造函数
A b = a;    // 赋值函数
```


##### 1.构造函数

构造函数被用来对类的数据成员进行初始化和内存分配。

（**构造函数可以被重载，不能为虚函数，可以带多个参数**；析构函数只有一个，不能重载，不能带参数，可以为虚函数）

#####  2.拷贝构造函数

它是一种特殊的构造函数，用基于同一类的一个对象构造和初始化另一个对象。

当没有重载拷贝构造函数时，通过默认拷贝构造函数来创建一个对象：

构造函数会在用户没用明确定义时编译器自动生成，但这个时候的拷贝为**浅拷贝**（共用内存），如果用到了手动释放的对象，则可能会出现内存泄露问题（释放一个，另一个也被释放）。

所以，在对含有指针成员的对象进行拷贝时，必须自己定义拷贝构造函数，使拷贝后的对象指针成员有自己的内存空间（new 一个）。

拷贝构造函数重载声明为： 

```c++
A (const A & other)
```

##### 3.赋值函数

把一个新的对象赋值给一个原有的对象，如果原来的对象中有内存分配要先把内存释放掉，而且还要检查一个两个对象是不是同一个。

赋值函数是**两个对象都已存在**，重载声明为：

```c++
A& operator = (const A& other)
```

使用2和3的区别，2：复制指针对象； 3：引用指针对象

如果不想写拷贝构造函数和赋值函数，又不允许别人使用编译器自动生成，可以将构造函数和赋值函数声明为私有，不用编写代码。









类的数据成员默认为**私有**成员，但不绝对

类的成员函数默认为**公有**成员，但不绝对

封装，类的private成员只能在本类中访问，可以通过公用接口访问

继承，protected的作用就是这个目的；

　　protected成员可以被子类对象访问，但不能被类外的访问；





------

### 子类的构造和析构

##### 构造原则

1. 如果子类没有定义构造方法，则调用父类的无参数的构造方法。
2. 如果子类定义了构造方法，不论是无参数还是带参数，在创建子类的对象的时候，**首先执行父类无参数的构造方法**，然后执行自己的构造方法。
3. 在创建子类对象时候，如果子类的构造函数没有显式调用父类的构造函数且父类只定义了自己的有参构造函数，则会出错（如果父类只有有参数的构造方法，则子类必须显式调用此带参构造方法）

在调用带参数的构造函数时，加一个冒号（:），然后加上父类的带参数的构造函数。这样，在子类的构造函数被调用时，系统就会去调用父类的带参数的构造函数去构造对象。

这种初始化方式，还常用来对类中的常量（const）成员进行初始化



##### 为什么将类的构造函数设为私有的成员函数？

对共有成员，可以直接调用进行访问：

```c++
class Cat {
  public:
    int weight;   
};
int main() {
    Cat cat;//声明一个对象
    cat.weight=5;
    cout<<"The cat's weight is "<<cat.weight<<endl;
    return 0;
}
```

一般情况下，需要保证程序的安全性，防止造成错误的输入与输出。因为在类的公共接口函数中，我们可以对输入的具体值进行限定，那么就不会造成数据的错误。

如下例：

```c++
class Cat {
  public:
   void setWeight(int w) {
      if(w>0&&w<50)//这里，我们就可以通过一条简单的if语句启动控制作用
        weight=w;
   }//设置重量
   int print(){return weight;}//返回重量的大小
    
  private:
   int weight;   
};
```

​	我们可以将类的数据成员设置为私有的，然后调用类中的公共该接口函数来访问他们。这样做的好处是将数据的赋值与读取分开操作。比如说上例里面，我们就将数据的赋值函数设置成**setWeight(int)**，将数据的读取函数设置成**print()**。这样的好处就是赋值函数不需要考虑读取函数是如何工作的，读取函数中的代码改变也不会影响到相应的赋值函数。那么这样就提高了代码的可重用性。

​	另外，由于将数据成员进行了私有化，那么各个对象不可以直接访问并修改数据。比如说上例中想要直接修改**weight**的数值就是不合法的，只有通过公共的接口函数才能访问并且修改到类里面的私有数据成员（weight）。另一个好处是，类的设计提供给别人用的时候，类的用户不需要去思考设计者提供的到底是函数还是成员变量，一律当函数来调用就可以了。例如，不需要考虑getWeight是一个函数还是成员变量，一律用**getWeight()**来调用就可以了。

​    这样的设置时程序更容易维护，并且可避免一些不应有的错误。

------

### 虚函数和虚表

虚函数示例代码

```c++
class A{
    public:
        virtual void fun() {cout<<1<<endl;}
        virtual void fun2() {cout<<2<<endl;}
};
class B : public A{
    public:
        void fun() {cout<<3<<endl;}
        void fun2() {cout<<4<<endl;}
};
```

由于这两个类中有虚函数存在，所以**编译器**就会为他们两个分别插入一段你不知道的数据，并为他们分别创建一个表。那段数据叫做vptr指针，指向那个表。那个表叫做vtable，每个类都有自己的vtable，vtable的作用就是保存自己类中虚函数的地址，我们可以把vtable形象地看成一个数组，这个数组的每个元素存放的就是虚函数的地址，请看图

<img src="E:\笔记\C++其他\cpp笔记.assets\image-20210105204201896.png" alt="image-20210105204201896" style="zoom: 150%;" />

所以代码分析如下：

```c++
A *p = new A;
p->fun()
```

先调用A::fun()，过程为：首先取出vptr的值，再到vtable这，由于A::fun是第一个虚函数，所以取出vtable中第一个Slot的值，即第一个虚函数地址，再调用该函数。

虚函数因为要经过查表，所以执行效率稍微低一点。

> 定义虚函数的限制
>
> 1. 非类的成员函数不能定义为虚函数，类的成员函数中静态成员函数和构造函数也不能定义为虚函数，但可以将析构函数定义为虚函数。实际上，优秀的程序员常常==把基类的析构函数定义为虚函数==。因为，将基类的析构函数定义为虚函数后，当利用delete删除一个指向派生类定义的对象指针时，系统会调用相应的类的析构函数。而不将析构函数定义为虚函数时，只调用基类的析构函数。
> 2. 只需要在声明函数的类体中使用关键字“virtual”将函数声明为虚函数，而定义函数时不需要使用关键字“virtual”。
> 3. 当将基类中的某一成员函数声明为虚函数后，派生类中的==同名函数（函数名相同、参数列表完全一致、返回值类型相关）==自动成为虚函数。
> 4. 如果声明了某个成员函数为虚函数，则==在该类中不能出现和这个成员函数同名并且返回值、参数个数、类型都相同的非虚函数==。在以该类为基类的派生类中，也不能出现和这个成员函数同名并且返回值、参数个数、类型都相同的非虚函数。

纯虚函数是一种特殊的虚函数，它的实现留给该基类的派生类去做，它的一般格式如下

```c++
virtual <类型><函数名>(<参数表>)=0;
```

包含纯虚函数的类为抽象类。纯虚函数是不允许被实例化的，例如，老鼠、孔雀都属于动物，但动物不能被实例化。



相似概念：

C++支持两种[多态性](https://baike.baidu.com/item/多态性)：编译时多态性，[运行时多态性](https://baike.baidu.com/item/运行时多态性)。

a.编译时多态性：通过[重载函数](https://baike.baidu.com/item/重载函数)和运算符重载实现。

b运行时多态性：通过虚函数和继承实现。



##### 构造函数不可以是虚函数，而析构函数可以是虚函数？

为什么构造函数不可以是虚函数？

> 1. 构造一个对象的时候，必须知道对象的实际类型，而**虚函数行为是在运行期间确定实际类型的**。而在构造一个对象时，由于对象还未构造成功。编译器无法知道对象 的实际类型，是该类本身，还是该类的一个派生类，或是更深层次的派生类。无法确定。
>
> 2. 虚函数的执行依赖于虚函数表。而虚函数表在构造函数中进行初始化工作，即初始化vptr，让他指向正确的虚函数表。而在构造对象期间，**虚函数表还没有被初始化**，将无法进行。虚函数的意思就是开启动态绑定，程序会根据对象的动态类型来选择要调用的方法。然而在构造函数运行的时候，这个对象的动态类型还不完整，没有办法确定它到底是什么类型，故构造函数不能动态绑定。

析构函数可以声明为虚函数，而且有时是必须声明为虚函数。

> 析构函数设为虚函数的作用: 在类的继承中，如果有**基类指针指向派生类**，那么用基类指针delete时，如果不定义成虚函数，派生类中派生的那部分无法析构。
>
> 基类的析构函数不声明为虚函数容易造成**内存泄漏**。

记得，在构造函数和析构函数中尽量不要调用虚函数。如果在基类的构造中调用虚函数，如果可以的话就是调用一个还没有被初始化的对象，那是很危险的，所以C++中是不可以在构造父类对象部分的时候调用子类的虚函数实现。

在析构函数中也不要调用虚函数。在析构的时候会首先调用子类的析构函数，析构掉对象中的子类部分，然后在调用基类的析构函数析构基类部分，如果在基类的析构函数里面调用虚函数，会导致其调用已经析构了的子类对象里面的函数，这是非常危险的。

------
C++之静态成员和静态成员函数

·静态成员为该类的所有对象所共享，因此不能在类内部进行赋值，只能在类体外进行初始化，一般形式为：

数据类型类名：：静态数据成员名＝初值

·静态成员是类所有的对象共享成员，不是某个对象的成员。它在对象中不占用存储空间，这个属性为整个类所共有，不属于任何一个具体对象。

它没有this指针，因此静态成员函数与类的全局函数相比速度上会有少许的增长

静态成员函数不能调用非静态数据成员，要通过类的对象来调用。

静态成员之间可以相互访问，包括静态成员函数访问静态数据成员和访问静态成员函数

非静态成员函数可以任意地访问静态成员函数和静态数据成员



------

### C++ 内存分配(new，operator new)

##### new operator 和 operator new

new operator，是指在c++ 里通常用到的关键字。比如 A *a = new A;

operator new，是一个操作符，且可以被重载（类似于加减乘数）

在用new的过程中，系统操作分为三步：

```c++
A *a = new A;
```

1. 分配内存，调用 operator new(sizeof(A))

   如果A重载了operator new，则调用A::operator new(size_t)

2. 调用A()构造对象，调用A::A()

3. 返回分配指针



##### 指针的释放或删除

**new** 与 **delete** 成对出现 **malloc**与**free**（源自c）成对出现

malloc与free： malloc申请内存是在堆里（一般局部变量为栈），如果不手动free掉，会造成内存泄露。如：

```c++
Car* car = (Car*)malloc(sizeof(Car)); 
free(car)
```

new与delete：尽量使用这种方式， 这两个都是c++的运算符，且可以被重载。new是类型安全的，即在编译过程中出现错误可以指出，但malloc不是。





内存泄露

https://www.cnblogs.com/zzdbullet/p/10478744.html

几种情况：

1、在类的构造函数和析构函数中没有匹配的调用new和delete

 一是在堆里创建了对象占用了内存，但是没有显示地释放对象占用的内存；二是在类的构造函数中动态的分配了内存，但是在析构函数中没有释放内存或者没有正确的释放内存

2、没有正确地清除嵌套的对象指针

3、在释放对象数组时在delete中没有使用方括号

 方括号是告诉编译器这个指针指向的是一个对象数组。如果没有方括号，那么这个指针就被默认为只指向一个对象，对象数组中的其他对象的析构函数就不会被调用，结果造成了内存泄露。且方括号中的数字大小不能过大，过小。过大容易导致崩溃，过小会造成泄漏。

4、指向对象的指针数组不等同于对象数组

 对象数组是指：数组中存放的对象，只需要delete []p，即可调用对象数组中每个对象的析构函数释放空间。

 指向对象的指针数组是指：数组中存放的是指向对象的指针，不仅要释放每个对象的空间，还要释放每个指针的空间，delete []p只是释放了每个指针，但是并没有释放对象的空间，正确的做法，是通过一个循环，将每个对象释放了，然后再把指针释放了。

5、缺少拷贝构造函数

 调用的默认拷贝构造函数，会使得类的指针成员变量指向同一内存，如果释放，则会造成内存泄露。

6、缺少重载赋值运算符

 和上述的问题类似。

7、关于nonmodifying运算符重载的常见迷思

 a. 返回栈上对象的引用或者指针（也即返回局部对象的引用或者指针）。导致最后返回的是一个空引用或者空指针，因此变成野指针。

 b. 返回内部静态对象的引用。

 c. 返回一个泄露内存的动态分配的对象。导致内存泄露，并且无法回收。

解决这一类问题的办法是重载运算符的返回值不是类型的引用，二应该是类型的返回值，即不是int&而是int

8、没有将基类的析构函数定义为虚函数

 当基类指针指向子类对象时，如果基类的析构函数不是virtual，那么子类的析构函数将不会被调用，子类的资源没有正确释放。

 

野指针：

1.指针变量没有被初始化，如果值不定，可以设置为NULL。

2.指针被free或delete后，没有置为NULL，free和delete只是把指针内存释放掉，并没有把指针本身干掉，此时指针指向“垃圾内存”。

3.指针操作超越了变量的作用范围，比如返回指向栈内存的指针就是野指针。

 

c语言中指针和内存泄露

http://www.cnblogs.com/archimedes/p/c-point-memory-leak.html



---

### 静态成员和静态成员函数

- 静态成员为该类的所有对象所共享，因此不能在类内部进行赋值，只能在类体外进行初始化，一般形式为：

  数据类型类名：：静态数据成员名＝初值

- 静态成员是类所有的对象共享成员，不是某个对象的成员。它在对象中不占用存储空间，这个属性为整个类所共有，不属于任何一个具体对象。

它没有this指针，因此静态成员函数与类的全局函数相比速度上会有少许的增长

静态成员函数不能调用非静态数据成员，要通过类的对象来调用。

静态成员之间可以相互访问，包括静态成员函数访问静态数据成员和访问静态成员函数

非静态成员函数可以任意地访问静态成员函数和静态数据成员



全局静态变量，存储在系统的**静态存储区**，可以为全局所用。

函数静态变量，可以使得外界进行调用。静态函数也可以在没有对象的情况下进行调用，一般在框架设计上用做Util或Mgr或Attr或API等。

一般情况下，静态函数的作用域在本cpp文件中，除非声明为全局，或被其他文件包含。

> static 关键字的作用
>
> 将变量转换为静态变量，当修饰函数时，只能在源文件中定义，在实现文件中进行转换。



### 友元函数



---

### Lambda 函数

Lambda 的语法形式如下：

```c++
[函数对象参数] (操作符重载函数参数) mutable 或 exception 声明 -> 返回值类型 {函数体}
```

args： 

1. [函数对象参数] （无法省略）函数对象参数是传递给编译器自动生成的函数对象类的**构造函数**的。

   可以有以下几种形式：

   - 空。没有任何函数对象参数。

   （以下几个都是函数体内可以使用Lambda所在范围内所有的可见的局部变量（包括Lambda所在类的this）

   - =。 值传递方式。（任何用到的外部变量）

   - &。引用传递方式。（任何用到的外部变量）

   - this。函数体内可以使用Lambda所在类中的成员变量
   
   - a 将a按值进行传递。默认情况下函数是const的，要修改传递进来的拷贝，用mutable
   
   - &a 将a按引用进行传递
   
   - a, &b 将a按值传递，b按引用进行传递
   
   - =，&a，&b 除a和b按引用进行传递外，其他参数都按照值进行传递
   
   - &，a，b 除a和b按值进行传递外，其他参数都按引用进行传递

 

2. （操作符重载函数参数） —— 可省略

   参数可以通过按值（如（a，b））和按引用（如：（&a，&b））两种方式进行传递。

 

3. mutable和exception声明 —— 可省略

   按值传递函数对象参数时，加上mutable修饰符后，可以修改传递进来的拷贝。

   exception声明用于指定函数抛出的异常，如抛出整数类型的异常，可以用throw(int)

 

4. -> 返回值类型 —— 可省略

   标识函数返回值类型，当返回值为void，或者函数体中只有一处return的地方（可自动推断返回值类型）

 

5. {函数体} 可为空但不能省略

   实例：

   ```c++
   [] (int x, int y) { return x + y; } // 隐式返回类型
   
   [] (int& x) { ++x; } // 没有 return 语句 -> Lambda 函数的返回类型是 'void'
   
   [] () { ++global_x; } // 没有参数，仅访问某个全局变量
   
   [] { ++global_x; } // 与上一个相同，省略了 (操作符重载函数参数)
   
   [] (int x, int y) -> int { int z = x + y; return z; } // 显示指定返回类型
   ```

    
   
   一般情况下，会结合std::for_each（用法稍微陈旧了一些）进行使用。例如：
   
   ​     std::for_each(nums.begin(), nums.end(), [](int &n){ n++; });
   
   而std::for_each的效率和for循环效率差不多，只不过能稍微减少一点错误。
   
   std::for_each(iter.begin()，iter.end() ，Lambda )

 

一般对于遍历容器中的所有元素可以有以下几种形式：

第一种：

for (std::vector<int>::iterator**//**const_iterator it = ve.begin()**//**cbegin(); it <**//**!= ve.end(); ++it)  f(*it)

书写复杂，并不是所有的迭代器都支持小于操作，容易误写成 <= ve.end()

第二种：

for(std::size_t i = 0; i < ve.size(); ++i) 

​     f(ve[i])

.size()可能有效率问题，下标可能不规范，或size_t的移植问题，break或continue影响优化

第三种：

std::for_each(ve.begin(), ve.end(), f);

相比更好，但如果f过长，也不美观

第四种：

for (auto val : ve) 或 for (auto &val : ve)

​     f(val)

什么都好，就是要c++ 11之后

 

-------

### STL系列

#### 总述

STL结构和内存分配

1. **vector**

   存储为**连续内存**，容量等于其内元素个数，当进行插入时，如果内存不够，则会重新分配内存空间（大小为原来的3/2），它的iterator是random access iterator（结构包含cur，first，last，node）。

2. **list**

   内存空间是链式存储是一个**环状的双向链表**，插入和删除都是常数时间。每次分配一个内存空间，iterator不是普通的指针，而是可以++和--操作的。

3. **deque**

   存储空间是双向开口的线性空间，表面上是连续的，但实际上是**一段一段连续空间的组合**。因为是连续空间，所以要一个中控器对其进行管理，中控器是一段连续的空间，每个元素都是一个指针，指向另一段比较大的连续线性空间。iterator是random access iterator。

4. **stack**

   可以将deque作为底层容器，也可以将list作为底层容器，没有迭代器。

5. **queue**

   可以将deque作为底层容器，也可以将list作为容器，没有迭代器。

6. **heap**

   是STL的幕后黑手，可以帮助实现priority queue，binary heap是一个完全二叉树，以vector为容器。

7. **priority_queue**

   是一个大根堆，以vector为底层容器，没有迭代器。

8. **slist**

   单向列表，和list的主要区别是单向，这样会节省很多空间。有迭代器，但只能单向。不是环状，最后一个元素指向0。



##### vector

头文件 \<vector\>

栈结构：先进后出，后进先出

方法列表：

- 构造

  ```c++
  // 构造赋值
  vector<int> c1;    //初始化一个空的vector，元素个数size为0，可以随后用resize
  vector<int> c2(10);  //size = 10, elem = 0;
  vector<int> c3(10, 1);   // size = 10, elem = 1;
  /* 
  二维vector初始化
  vector<vector<int> > newOne(m, vector<int>(n, 0));   // m rows, n lines vector
  
  也可以用resize来控制大小
  vector<vector<int> > newOne;
  newOne.resize(m);
  for (int k = 0; k < m, ++k) {
    newOne[k].resize(n);
  }
  
  如果每一行列数不一样，建议使用push_back(vector<int>)来表示。
  */
  
  // 直接赋值初始化
  vector<int> c4{1, 2, 3}; 
  vector<vector<int> > c5{{1, 2, 3}, {4, 5, 6}}; 
  
  // 数组转容器
  int a[5] = {1,2,3,4,5}; //通过数组a的地址下标初始化，从index1开始到index2作为a的初值
  vector<int> c(a, a+5);  // 或者 vector<int> c(a, a+sizeof(a)/sizeof(int));
  
  // 同类型的vector初始化
  vector<int> c1(5, 1);
  vector<int> c2(c1);  //或 vector<int> c2(c1.begin(), c2.begin()+3);  用来切分子数组
  					 //或 vector<int> c2(c1, 0, 3); 
  
  ```

- 关于迭代器

  ```c++
  begin(), end(), rbegin(), rend()     // 正向、反向迭代器
  cbegin(), cend(), crbegin(), crend()   // const迭代器
  ```

- 关于容量

  ```c++
  size(), capacity(), max_size() // 当前大小，容量（一般由reverse申请，大于当前大小），容量最大值
  resize(), reserve() // 区别，reverse()是预留空间，并不创建元素；resize()改变大小并创建对象
  empty()          // 是否为空
  shrink_to_fit()    // 将容量缩小为size大小
  ```

  vector的容器的大小不能超过它的容量，在大小等于容量的基础上，只要增加一个元素，就必须分配更多的内存。size() <= capacity()

- 元素访问

  ```c++
  operator[], at()     // 访问第n个元素，at会进行下标越界检查，越界会抛出异常，速度相对稍慢
  front(), back()      // 返回首、末元素
  data()           // 返回以T *类型的数组，可利用指针方式进行元素修改
  ```

- 元素修改

  ```c++
  push_back(), insert()
  pop_back(), clear(), erase(int pos)
  assign(int n, int elem)  // 或用(Interator first, Interator second);
  swap()
  emplace(), emplace_back()  // cxx11
  ```

  - c++姿势点：push_back和emplace_back

    1. **接受构造参数**：push_back只支持实例，emplace_back还接受该类型的构造函数的参数

       当vector的类型（`vector\<type\>`）是我们自定义类型（ `user_defined type`）：class或者struct，并且这个类型接受多个构造参数，那么push*_*back需要传一个对象（`object`），emplace_back可以只将构造参数传进去

       ```c++
       vec.push_back(New(34, "Happy"));  // work fine
       vec.emplace_back(41 , "Shanks");  // work fine
       ```

       emplace_back是可以接受一个参数列表的，即变模板参数。

    2. **性能（开销更少）**

       内置类型基本相同，而对用户自定义类型：`emplace_back`仅在通过使用构造参数传入的时候更高效。

       因为 `push_back` 在实际的执行过程中，会实现拷贝构造函数。可以重载拷贝构造函数进行测试。而 `emplace_back` 只会实现构造函数。

- 几种重要的算法，使用时需要包含头文件：

  ```c++
  #include<algorithm>
  
  sort(a.begin(), a.end());  //对两个迭代器之间的内容进行排序
  reverse(a.begin(), a.end());   //对a中内容翻转
  copy(a.begin(), a.end(), b.begin());//把a中内容复制到b中，从b.begin()开始，并覆盖掉原有元素
  find(a.begin(), a.end(), 10);   //在a中从查找10，若存在返回其在向量中的位置
  ```

##### map

头文件 \<map\>

map是`STL`的一个关联容器，它提供一对一的hash。

> 关联性：其中元素根据键来引用，而不是索引
>
> 有序性：总是按照其内部的比较器指示的特定严格弱序标准按其键排序
>
> 唯一性：元素的键是唯一的，即每个关键字key只能在map中出现一次

map內部的实现自建一颗==红黑树==，这颗树具有对数据自动排序的功能。

map对象是模板类，需要关键字和存储对象两个模板参数。

为了使用方便，可以对模板类进行一下类型定义，

```c++
typedef map<int,CString> UDT_MAP_INT_CSTRING;

UDT_MAP_INT_CSTRING enumMap;
```

方法列表：

- 构造

  ```c++
  map<int, string> mapStudent;   // 创建空map
  mapStudent.insert(pair<int, string>(000, "student_zero"));  //用insert函数插入pair
  mapStudent.insert(map<int, string>::value_type(001, "student_one"));  //用insert函数插入value_type数据
  mapStudent[123] = "student_first";       //用"array"方式插入
  
  // 加入比较函数等
  struct classcomp {
    bool operator() (const char& lhs, const char& rhs) const
    {return lhs<rhs;}
  };
  std::map<char,int,classcomp> fourth;   // 结构体类型
  
  bool fncomp (char lhs, char rhs) {return lhs<rhs;}
  bool(*fn_pt)(char,char) = fncomp;
  std::map<char,int,bool(*)(char,char)> fifth(fn_pt); // 函数指针作比较
  ```

  即当map中有这个关键字时，`insert`操作是不能在插入数据的，但是用数组方式(`array`)就不同了，它可以==覆盖==以前该关键字对应的值。

- 关于迭代器

  ```c++
  begin(), end(), rbegin(), rend()     // 正向、反向迭代器
  cbegin(), cend(), crbegin(), crend()   // const迭代器
  ```
  
  在使用迭代器时，因为map是有序的，所以正向迭代器的key是有序的，默认为升序。
  
- 关于容量

  ```c++
  size(), max_size() // 当前大小，容量最大值
  empty()          // 是否为空
  ```

- 元素访问

  ```c++
  operator[], at()     // 根据key访问value，at会进行下标越界检查，越界会抛出异常，速度相对稍慢
  ```

- 元素修改

  ```c++
  insert()   // 使用可参见构造函数，需要加入pair对
  erase()    // 可接受迭代器（单个和范围）和关键字删除；删除关键字成功返回1，否则为0
  swap()     // 交换两个map， map1.swap(map2);
  clear()    // 清空map
  emplace()   // 不需要构建pair对，就可以插入  emplace(key, value);
  emplace_hint()  // 第一个参数 emplace(iterator, key, value);  返回迭代器的位置
  ```
  
  `emplace` 和 `insert` 最大的区别点，在于`emplace`避免产生了不必要的临时变量，因为它使用了`c++11`的两个新特性**变参模板**和**完美转发**。 因此emplace效率比insert高。

- 操作属性

  ```c++
  find()   // 如果被查找的元素key存在，则返回key位置的迭代器，否则返回map.end()
  count()   // 返回容器中某个元素的数量，由于map的key唯一，所以只能返回1或0
  lower_bound(),  upper_bound()  // 返回以key为边界的迭代器的位置，分为上边界和下边界
  equal_range()  // 返回迭代器位置区间 [lower_bound, upper_bound)
    // std::pair<std::map<char,int>::iterator,std::map<char,int>::iterator> ret;
    // 如果存在，ret->first为lower_bound，ret->second为upper_bound
  ```

- 内存分配

  ```c++
  get_allocator()  // 为map分配内存
  ```

> multimap中的key是可以重复的，而map中的key是唯一的

##### unordered_map

头文件 \<unordered_map\>

与map相比相同的函数用 `=` 表示，相比map增加的函数用`+` 表示，相比map去掉的函数用`-`表示

方法列表：

- 构造

  ```c++
  std::unordered_map<std::string,std::string> mymap = {
      {"us","United States"},
      {"uk","United Kingdom"},
      {"fr","France"},
      {"de","Germany"} 
  }                   //  + 用列表直接初始化
  std::unordered_map<std::string,std::string> stringmap (vec.begin(),vec.end());
  ```

- 关于迭代器

  ```c++
  begin(), end(), cbegin(), cend()  // =
  // - rbegin(), rend(), rcbegin(), rcend()
  ```

- 关于容量

  ```c++
  size(), max_size()，empty()  // =
  ```
  
- 元素访问

  ```c++
  operator[], at()     // =
  ```

- 元素查找

  ```c++
  find(), count(), equal_range() // = 
  ```

- 元素修改

  ```c++
  insert(), erase(), swap(), clear(), emplace(), emplace_hint()  // =
  ```

- 桶

  ```c++
  bucket_count()  // 当前桶的数量
  max_bucket_count()  // 最大桶的数量
  bucket_size(size_type n)   // 返回第n个桶内元素的数量
  bucket_size(key)  // 返回key所在桶的索引
  ```

- Hash 策略

  ```c++
  load_factor()  // load_factor = size / bucket_count
  max_load_factor()  // 初始值为1，如果重载有形参float a，则会修改最大load factor为a
  rehash()  // 将容器的桶数量设为大于等于n的数
  reverse()  // 如果n大于当前桶的数量乘max_load_factor，桶的容量会增加，且进行rehash()
  ```

- 其他类型

  ```c++
  hash_function(),  key_eq(),  get_allocator()  //获取hash函数，键值比较，容量分配
  ```

###### 各种Hash函数和代码

[总结的一些字符串哈希函数](http://www.cppblog.com/bellgrade/archive/2009/09/29/97565.html)  c语言实现



###### map和unorderd_map的区别

map与unordered_map。这两种容器在不同场景下的作用是不同的，应用得当对优化性能有不小的帮助。

|          | map          | unordered_map        |
| -------- | :------------: | :--------------------: |
| 实现原理 | 红黑树 | 哈希表 |
| 构造 | 元素逐一添加 | 可以用list进行初始化 |
| 删除、查找效率 | O(log n) | O(1) |
| 优点 |有序 |效率较高 |
|缺点|进行大量操作效率低|需要额外存储空间|
| 使用条件 | 需要**有序性**或对**单次查询**有时间要求 | 其余情况 |

- map是基于红黑树实现。红黑树作为一种自平衡二叉树，保障了良好的最坏情况运行时间，即它可以做到在O(log n)时间内完成查找，插入和删除，在对单次时间敏感的场景下比较建议使用map做为容器。比如实时应用，可以保证最坏情况的运行时间也在预期之内。

  另红黑树是一种二叉查找树，二叉查找树一个重要的性质是有序，且中序遍历时取出的元素是有序的。对于一些需要用到有序性的应用场景，应使用map。

- unordered_map是基于hash_table实现，一般是由一个大vector，vector元素节点可挂接链表来解决冲突来实现。hash_table最大的优点，就是把数据的存储和查找消耗的时间大大降低，几乎可以看成是常数时间；而代价仅仅是消耗比较多的内存。然而在当前可利用内存越来越多的情况下，用空间换时间的做法是值得的。

  值得注意的是，在使用unordered_map设置合适的hash方法，可以获得良好的性能。

##### set/unordered_set

set可以认为是 key 和 value 相同的map，它的底层和对应的map相同，且所有API和map相同。



##### list

list被实现为双向链表，它的每个元素存储在不同且不相关的存储位置中。

因此它的内存空间是不连续的，通过指针来进行数据的访问，这个特点使得它的随即存取变的非常没有效率，因此它没有提供[]操作符的重载。

但由于链表的特点，它可以以很好的效率支持任意地方的删除和插入

头文件 \<list\>

方法列表：

- 构造

  ```c++
  // 构造赋值
  list<int> c1;    //初始化一个空的list
  list<int> c2(10);  //size = 10, elem = 0;
  list<int> c3(10, 1);   // size = 10, elem = 1;
  
  // 同类型的list初始化
  list<int> c2(c1);
  // 迭代器初始化
  list<int> c2(c1.begin(), c2.begin());
  ```
  
- 关于迭代器

  ```c++
  begin(), end(), rbegin(), rend()     // 正向、反向迭代器
  cbegin(), cend(), crbegin(), crend()   // const迭代器
  ```

- 关于容量

  ```c++
  size(), max_size() // 当前大小，容量最大值
  empty()          // 是否为空
  ```
  
- 元素访问

  ```c++
  front(), back()      // 返回首、末元素
  ```
  
- 元素修改

  ```c++
  assign(int n, int elem)  或  assign(iter1, iter2);
  emplace_front(), push_front(), pop_front() // 对列表首进行增减
  emplace_back(), push_back(), pop_back()  // 对列表尾进行增减
  emplace(), insert()  // 第一个参数为pos, 后面为插入的值或构造函数
  erase()  // position 或 position range
  swap()
  resize()  // 去掉多余的，或扩充到一定的容量
  clear()
  ```

- 操作符

  ```c++
  splice(pos, list, iter)   // 实现list拼接的功能。将源list的内容部分或全部元素删除，拼插入到目的list。
  remove(val)   // 删除list中等于val的元素
  remove_if(expression)  // 删除list中符合表达式的元素
  unique()   // 删除重复的元素，或符合表达式的元素
  merge()   // first.merge(second)  first和second均有序，合并为有序list, 并清空second
  sort()   //  O(NlogN)  stable
  reverse()
  ```


与其他基本的序列容器（array、vector和deque）相比，列表在插入、提取和移动比其他的表现更好，因此在使用大量元素的算法中较常用（如 排序算法）。



##### forward_list

单向链表。它允许在序列中任何位置以常量时间进行插入和删除操作。

它和list的区别在于，对于每一个节点，它只有单向指向，因此它相对list会更加高效。

与array、vector、deque等容器相比，它在插入、获取、移动元素相对高效。但缺点是不能根据元素位置直接访问元素。

头文件\<forward_list\>

方法列表：

- 构造

  ```c++
  forward_list<int> first;   // 空列表
  forward_list<int> second(3, 77);   // 填充构造
  forward_list<int> third = {3, 52, 25, 90};   // 列表初始化
  forward_list<int> forth(second);  // 赋值拷贝
  forward_list<int> fifth(move(second));  // move ctor.  second因为std::move作废
  ```
  
- 关于迭代器

  ```c++
  begin(), end(), cbegin(), cend();  
  before_begin(), cbefore_begin();  // before_begin 可以和 insert_after 联用在首位插入值
  ```

- 关于容量

  ```c++
  max_size()，empty();  // 无法直接获取size
  ```
  
- 元素访问

  ```c++
  front();     // 可直接访问首元素
  ```

- 元素修改

  ```c++
  assign();
  emplace_front(),  push_front(),  pop_front();  // 对首元素位置进行增/删操作
  emplace_after(),  insert_after(),  erase_after();  // 对某迭代器位置进行增/删操作
  resize();      // 从头开始删除多余元素，或填补空缺元素至一定数量
  clear();
  swap();
  ```

- 操作

  ```c++
  splice_after(pos, another_forward_list, iter_first, iter_last);  //从另一单向列表夺取部分值，插入到当前列表中
  remove(), remove_if();  // 移除元素
  unique();   // 按照要求删除重复元素
  merge();  // 对两个有序单向列表进行合并
  sort();
  reverse();  // 翻转单向列表
  ```




##### deque

发音类似于(*"deck"*)，是双端队列 double-ended queue的缩写。双端队列是具有动态大小的序列容器，可以在两端扩展或收缩。

它允许通过随机访问迭代器直接访问单个元素，相比vector，可以很好地在开头有效地插入和删除元素，但deque不能保证它所有的元素存储在连续的存储位置（通过指针偏移的方式来访问可能导致未定义行为）。这在对于特别长的序列，节省了一些重新分配内存的开销。

对于频繁插入或移除两端元素的操作，其性能不如list，迭代器和引用的一致性也不如list和forward_list。

头文件\<deque\>

方法列表：

- 构造

  ```c++
  // 构造赋值
  deque<int> d1;    //初始化一个空的deque，元素个数size为0
  deque<int> d2(10);  //size = 10, elem = 0;
  deque<int> d3(10, 1);   // size = 10, elem = 1;
  
  // 迭代器初始化
  int a[5] = {1,2,3,4,5}; //通过数组a的地址下标初始化，从index1开始到index2作为a的初值
  deque<int> d(a, a+5);  // 或者 deque<int> c(a, a+sizeof(a)/sizeof(int));
  deque<T> dd(Interator first, Interator last);
  
  // 同类型的deque初始化
  deque<int> d1(5, 1);
  deque<int> d2(c1);  //或 deque<int> c2(c1.begin(), c2.begin()+3);  用来切分子数组
  					 //或 deque<int> c2(c1, 0, 3); 
  ```
  
- 关于迭代器

  ```c++
  begin(), end(), rbegin(), rend()     // 正向、反向迭代器
  cbegin(), cend(), crbegin(), crend()   // const迭代器
  ```

- 关于容量

  ```c++
  size(), max_size() // 当前大小, 容量最大值
  resize()   // 若n小于当前大小，则保留前n个元素。否则，在末端添加值
  empty()          // 是否为空
  shrink_to_fit()    // 将容量缩小为size大小
  ```

- 元素访问

  ```c++
  operator[], at()     // 访问第n个元素，at会进行下标越界检查，越界会抛出异常，速度相对稍慢
  front(), back()      // 返回首、末元素的“引用”
  ```
  
- 元素修改

  ```c++
  push_back(), pop_back()
  push_front(), push_front()
  insert(), erase()
  emplace(), emplace_front(), emplace_back()    // cxx11
  assign(int n, int elem)  // 或 (Interator first, Interator second)
  swap()
  ```




##### queue

是一种 FIFO 队列，即可以先进先出，元素从容器的一端插入，从另一端提取。只能从容器”后面”压进(Push)元素,从容器”前面”提取(Pop)元素。

头文件\<queue\>

方法列表：

- 构造

  ```c++
  queue<int> first;  // an empty queue
  queue<int, list<int>> second; // an empty queue

  // 用 deque 或 list 进行初始化
  std::deque<int> mydeck (3,100);        // deque with 3 elements
  std::list<int> mylist (2,200);         // list with 2 elements

  queue<int> third(mydeck);
  queue<int, list<int>> forth(mylist);
  ```

- 其他操作

  ```c++
  empty();
  size();
  front();
  back();   // 注意它可以访问最后一个元素
  push();   // 在队列尾端添加元素
  emplace(); 
  pop();
  swap();
  ```

###### priority_queue

头文件也是\<queue\>

从queue衍生出的优先队列。优先队列是弱有序的，它内部是由堆构成。有最高级先出（first in, largest out）的行为特征。

```c++
//升序队列，小顶堆
priority_queue<int, vector<int>, greater<int>> q;
//降序队列，大顶堆
priority_queue<int, vector<int>, less<int>>q;
priority_queue<int> q;        // 在不声明的时候，默认是大顶堆

//greater和less是std实现的两个仿函数（就是使一个类的使用看上去像一个函数。其实现就是类中实现一个operator()，这个类就有了类似函数的行为，就是一个仿函数类了）
```

按照任意顺序push。在逐一pop的过程中，是按照一定顺序pop的。

相比queue，它少了以下几个方法：

```c++
front(); 
back();   // 因为只考虑优先出队列的值，所以不能返回末端
```

多了：

```c++
top();  // 代替了front()，返回优先返回的值
```



##### stack

栈 LIFO (last-in first-out)， 元素只能从容器的一端插入和提取。

头文件 \<stack\>

方法

- 构造

  ```c++
  stack<int> first;   // empty stack
  
  // 用其他容器进行初始化
  deque<int> mydeque(3, 100);
  vector<int> myvector(2, 100);
  
  stack<int> second(mydeque);
  stack<int, vector<int>> third(myvector);
  ```

- 其他方法

  ```c++
  empty(), size();     // 大小
  top();              // 返回 stack top元素的引用
  push(), emplace(); 
  pop();             // 移除顶部元素
  swap();
  ```

  

#### 迭代器部分特性

```c++
std::advance(InputIterator& it, int n);  // 对非随机访问的迭代器进行n次 ++或 --以移动到相应位置
std::next(ForwardIterator it， int n);  // 返回前向迭代器 ++ n次的位置，但不改变迭代器本身位置
std::prev(BidirectionalIterator it, int n);  // 返回迭代器 -- n次的位置
std::distance(InputIterator first, InputIterator last);  // 返回两个迭代器间的距离
```



至此，总结一下STL中自带一些排序功能的结构：map/set的key，和priority_queue的top()。

***





### c++11 新特性一览

https://blog.csdn.net/jiange_zh/article/details/79356417?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.control



// 使用noexcept表明函数或操作不会发生异常，会给编译器更大的优化空间。



---

### algorithm

#### max 和 max_element

- max(a,b)，返回a,b两者之间的较大值

- max_element(r, r+6),返回数组r中[0, 6)之间的最大值的迭代器，
  使用max_element返回的值减去数组头地址即为该最大值在数组的序号
- **min** 和 **min_element**的区别同上











文件流读写

https://blog.csdn.net/luo809976897/article/details/51442070

### 运算符优先级

TODO

| **优先级**      | **运算符**                                     | **说明**                  | **结合性** |
| --------------- | ---------------------------------------------- | ------------------------- | ---------- |
| 1               | ::                                             | 范围解析                  | 自左向右   |
| 2               | ++ --                                          | 后缀自增/后缀自减         |            |
| ()              | 括号                                           |                           |            |
| []              | 数组下标                                       |                           |            |
| .               | 成员选择（对象）                               |                           |            |
| −>              | 成员选择（指针）                               |                           |            |
| 3               | ++ --                                          | 前缀自增/前缀自减         | 自右向左   |
| + −             | 加/减                                          |                           |            |
| ! ~             | 逻辑非/按位取反                                |                           |            |
| (type)          | 强制类型转换                                   |                           |            |
| *               | 取指针指向的值                                 |                           |            |
| &               | 某某的地址                                     |                           |            |
| sizeof          | 某某的大小                                     |                           |            |
| new,new[]       | 动态内存分配/动态数组内存分配                  |                           |            |
| delete,delete[] | 动态内存释放/动态数组内存释放                  |                           |            |
| 4               | .* ->*                                         | 成员对象选择/成员指针选择 | 自左向右   |
| 5               | * /  %                                         | 乘法/除法/取余            |            |
| 6               | + −                                            | 加号/减号                 |            |
| 7               | << >>                                          | 位左移/位右移             |            |
| 8               | < <=                                           | 小于/小于等于             |            |
| > >=            | 大于/大于等于                                  |                           |            |
| 9               | == !=                                          | 等于/不等于               |            |
| 10              | &                                              | 按位与                    |            |
| 11              | ^                                              | 按位异或                  |            |
| 12              | \|                                             | 按位或                    |            |
| 13              | &&                                             | 与运算                    |            |
| 14              | \|\|                                           | 或运算                    |            |
| 15              | ?:                                             | 三目运算符                | 自右向左   |
| 16              | =                                              | 赋值                      |            |
| += −=           | 相加后赋值/相减后赋值                          |                           |            |
| *= /=  %=       | 相乘后赋值/相除后赋值/取余后赋值               |                           |            |
| <<= >>=         | 位左移赋值/位右移赋值                          |                           |            |
| &= ^= \|=       | 位与运算后赋值/位异或运算后赋值/位或运算后赋值 |                           |            |
| 17              | throw                                          | 抛出异常                  |            |
| 18              | ,                                              | 逗号                      | 自左向右   |





### gdb调试

编译，简单的编译为 g++  a.cc -o a

则a是可执行文件，用./a即可以执行。

如果使用c++11进行编译，则需要变为 g++  a.cc  -std=c++11 -o a



首先用mkd编译为debug版本，假设为procise-debug

`gdb procise-debug`

操作命令

| 命令 |  作用  |
| :-: | :-: |
| b/break main.cc:123 |   在main.cc的123行设置断点  |
|  info breakpoint   |  查看断点信息 |
|   r/run   |  运行至第一个断点  |
| n/next  | 下一行，单步执行，不进入函数   |
|  s/step   |  下一步，包含进入函数                     |
| c/continue   |   下一循环或前进到下一断点      |
|   u/until     |    跳出循环体      |
|   u+行号   |   运行至某一行       |
|  finish  | 运行程序直到当前函数完成返回<br />并打印函数返回值的堆栈地址和返回值及参数值 |
|p/print var|打印变量var|
|disp var|遇到变量var就打印|
|whatis|打印类型|
|delete断点号|删除第n个断点|
|dis/disable  enable  断点号|暂停 开启第n个断点|
|clear 行号|清除第n行的断点|
|l/list|显示程序的源代码，默认每次显示10行|
|l 行号/函数名|显示以行号为中心的10行代码/函数的源代码|
|回车|重复上一条命令|
|bt/backtrace|查看函数调用堆栈|
|q/quit|退出|



将GDB中需要的调试信息输出到文件

| 命令 | 作用 |
| :----: | :----: |
| (gdb) set logging file <文件名> | 设置输出的文件名称  |
| (gdb) set logging on|此后的调试信息将输出到指定文件|
|(gdb) thread apply all bt|打印所有线程栈信息|
|(gdb) set logging off|关闭到指定文件的输出|





---

### 异常捕获与处理

程序运行时常会碰到一些异常情况，例如：

- 做除法的时候除数为 0；
- 用户输入年龄时输入了一个负数；
- 用 new 运算符动态分配空间时，空间不够导致无法分配；
- 访问数组元素时，下标越界；打开文件读取时，文件不存在。

这些异常情况，如果不能发现并加以处理，很可能会导致程序崩溃。

所谓“处理”，可以是给出错误提示信息，然后让程序沿一条不会出错的路径继续执行；也可能是不得不结束程序，但在结束前做一些必要的工作，如将内存中的数据写入文件、关闭打开的文件、释放动态分配的内存空间等。

将异常分散在各处进行处理不利于代码的维护，尤其是对于在不同地方发生的同一种异常，都要编写相同的处理代码也是一种不必要的重复和冗余。如果能在发生各种异常时让程序都执行到同一个地方，这个地方能够对异常进行集中处理，则程序就会更容易编写、维护。

`C++`引入了异常处理机制。假定B调用A，A在执行时发现异常，可以不处理，而是可以“抛出异常”给B。

拋出异常而不加处理会导致函数 A 立即中止，在这种情况下，函数 B 可以选择捕获 A 拋出的异常进行处理，也可以选择置之不理。如果置之不理，这个异常就会被拋给 B 的调用者，以此类推，直到main()函数。

#### throw

C++ 通过 throw 语句和 try...catch 语句实现对异常的处理。throw 语句的语法如下：

```c++
throw 表达式;
```

该语句拋出一个异常。异常是一个表达式，其值的类型可以是基本类型，也可以是类。

#### try && catch

try...catch 语句的语法如下：

```c++
try {
    语句组
}
catch(异常类型) {
    异常处理代码
}
...
catch(异常类型) {
    异常处理代码
}
```

catch 可以有多个，但至少要有一个。

 不妨把 try 和其后`{}`中的内容称作“try块”，把 catch 和其后`{}`中的内容称作“catch块”。

 try...catch 语句的执行过程是：

- 执行 try 块中的语句，如果执行的过程中没有异常拋出，那么执行完后就执行最后一个 catch 块后面的语句，所有 catch 块中的语句都不会被执行；
- 如果 try 块执行的过程中拋出了异常，那么拋出异常后立即跳转到第一个“异常类型”和拋出的异常类型匹配的 catch 块中执行（称作异常被该 catch 块“捕获”），执行完后再跳转到最后一个 catch 块后面继续执行。

##### 能够捕获任何异常的 catch 语句

```c++
catch (...) {
  ...
}
```

这样的 catch 块能够捕获任何还没有被捕获的异常。

由于`catch(...)`能匹配任何类型的异常，它后面的 catch 块实际上就不起作用，因此不要将它写在其他 catch 块前面。

和 `switch` 语句的 `default` 有点像。

#### 异常再抛出

如果一个函数在执行过程中拋出的异常在本函数内就被 catch 块捕获并处理，那么该异常就不会拋给这个函数的调用者（也称为“上一层的函数”）；如果异常在本函数中没有被处理，则它就会被拋给上一层的函数。

在这里，处理指的是，在catch代码段中，不再添加throw语句。而继续抛出异常即为在catch中，单独添加throw一行。

##### 函数的异常声明列表

为了增强程序的可读性和可维护性，使程序员在使用一个函数时就能看出这个函数可能会拋出哪些异常，C++ 允许在函数声明和定义时，加上它所能拋出的异常的列表，具体写法如下：

```c++
void func() throw (int, double, A, B, C);
```

或

```c++
void func() throw (int, double, A, B, C){...}
```

上面的写法表明 func 可能拋出 int 型、double 型以及 A、B、C 三种类型的异常。异常声明列表可以在函数声明时写，也可以在函数定义时写。如果两处都写，则两处应一致。





---

### boost

boost格式化输出

https://www.cnblogs.com/lzjsky/archive/2011/05/05/2037327.html









# 关于逆向

逆向相对于正向比较简单，但也需要学习很多知识。

在逆向的过程中，我更加详细的了解了C++的底层原理，和x86/x64汇编，掌握了一些软件开发框架的思路。对安全技术有一定的了解，如去字符化等。

了解一些哈希算法，熟悉使用IDA等工具进行调试分析。让我思维敏捷，喜欢与数字打交道。

另外，



new allocator

虚拟内存、物理内存

c++编译过程

僵尸进程、孤儿进程

内存池