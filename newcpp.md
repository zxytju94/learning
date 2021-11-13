####　枚举类型

effective c++第二条指出，尽量使用const ,enum代替define。在写程序的时候，需要入参为设备类型，第一反应是枚举一个设备类型，并以名字命名。类中的枚举到底是以什么形式存在的？枚举变量需不需要分配内存？

如果类的变量仅有一个枚举型，此时类的大小是一个int型变量的大小。取得的枚举是一个整形。可以通过类域访问到枚举值。

为什么通过 类::enum值可以访问枚举值？

> 因为该枚举是一个常量，在编译的时候已经被放入了**常量区**。调用的时候因此不需要该枚举的变量也可以调用。

注意：枚举类型不具备名字空间的作用。在一个作用域中在，如果两个枚举类型的值相同，则会编译出错。

```c++
struct CEType
{
  enum EType1 { e1, e2 };
  enum EType2 { e1, e2 };
};
```

e1,e2名字相同程序会报错。



#### 友元

​	有些情况下，允许特定的非成员函数**访问**一个类的**私有成员**，同时仍阻止一般的访问，这是很方便做到的。例如被重载的操作符，如输入或输出操作符，经常需要访问类的私有数据成员。

​	友元(friend)机制允许一个类将对其非公有成员的访问权授予指定的函数或者类，友元的声明以friend开始，它只能出现在类定义的内部，友元声明可以出现在类中的任何地方：友元不是授予友元关系的那个类的成员，所以它们不受其声明出现部分的访问控制影响。通常，将友元声明成组地放在类定义的开始或结尾是个好主意。

##### 友元函数

类的友元函数是定义在类外部，但有权访问类的所有私有（private）成员和保护（protected）成员。尽管友元函数的原型有在类的定义中出现过，但是友元函数并不是成员函数。





### c++11并发与多线程

一、总述以及基础要求、开发环境

a) c++中级以上水平

b) c++11的知识

开发环境：vs2017: windows

创建一个工程方便后续使用

windows 控制台应用程序

ctrl+f5，编译并运行

f9加断点，f5运行，f10 下一步



#### 一、并发、进程、线程

**并发：**（提升效率）

有两个或两个以上的任务（独立的活动），同时发生（进行），或者说**一个程序同时执行多个独立任务**。
 当cpu的数量少于任务数的时候，其实只是通过轮流调度来实现一种表面的并发进行。
 使用并发的原因：可以同时执行多个任务，有提高性能的作用

**进程：**

可以理解为一个正在执行的可执行程序。

可执行程序：windows下，扩展名为.exe；linux下，ls -la，rwx（可读可写可执行）

**线程：**

每个进程都有一个主线程，可以理解为代码的**执行通路**，我们可以写代码来创建其它线程，就可以实现，在同一个时间，在同一个进程执行多个任务
 线程并非越多越好，线程切换也是需要时间的，需要保存恢复各种局部变量。（一般200~300个为佳）

> 和进程比：线程有如下优点：
>
> 1. 线程启动速度更快，轻量级
> 2. 系统资源消耗更少，执行速度快，比如共享内存这种通信方式比其他任何的通信方式都快；
>
> 缺点：
>
> 1. 使用有一定难度，要小心处理数据的一致性问题



**多进程并发与多线程并发**

**多进程并发**相比于**多线程实现**并发而言，它还需要**切换虚拟地址空间**，开销更大。
**多进程之间**通信需要借助管道、文件、消息队列、共享内存（前面都是同一电脑上）、socket（不同电脑间）等通信技术手段。（本章外的技术）
**多线程之间**他们是共享一个虚拟地址空间的，即可以**共享内存**，线程间切换开销更小，但需要解决的一个重要问题就是：**要保证数据一致性**

> 全局变量、指针、引用都可以在线程之间传递，所以多线程开销小于多进程
>
> 数据一致性：线程A和线程B同时修改同一内存的问题（互斥锁）

以往在不同的开发平台上进行多线程开发都有不同的库、不同的函数，因此编写出来的程序一般不能跨平台。

> windows: CreateThread(), _beginthread(), _beginthredexe()
>
> Linux: pthread_create();
>
> 库 thread(pthread) 跨平台：需要做一些配置，用起来不方便

从c++11新标准开始，c++语言本身增加了**对多线程的支持**，使得编写的程序有了可移植性



####  二、创建线程的多种方法

1. **thread**
   （ 一定会创建线程，如果资源太紧张导致创建不了，程序就会崩溃 ）

   ```c++
   构造函数;
   thread() noexcept;   // 默认构造函数，创建一个空的执行对象
   
   template <class Fn, class...Args>   // 创建模板类，或模板函数，包括声明参数
   explicit thread (Fn&& fn, Args&&... args);   // 调用这些函数，可以看到是右值引用
   
   thread(const thread&) = delete;   // 拷贝构造函数（被禁用），即它不能被拷贝构造
   
   thread(thread&& x) noexcept;   //move构造函数，调用成功之后x不代表任何thread执行对象
   
   ```
   
   获取线程id;
      `std::this_thread::get_id();`
   
2. **async**
    （也叫创建一个异步任务，但当参数被指定为launch::deferred时，就不会创建线程）（同时相比thread，它一般用于需要返回值的线程） 

先讲区别：std::thread()如果系统资源紧张可能出现创建线程失败的情况，如果创建线程失败那么程序就可能崩溃，而且不容易拿到函数返回值（不是拿不到）
std::async()创建异步任务。可能创建线程也可能不创建线程，并且容易拿到线程入口函数的返回值；

由于系统资源限制：
①如果用std::thread创建的线程太多，则可能创建失败，系统报告异常，崩溃。

②如果用std::async，一般就不会报异常，因为如果系统资源紧张，无法创建新线程的时候，async不加额外参数的调用方式就不会创建新线程。而是在后续调用get()请求结果时执行在这个调用get()的线程上。

如果你强制async一定要创建新线程就要使用 std::launch::async 标记。承受的代价是，系统资源紧张时可能崩溃。

③根据经验，一个程序中线程数量 不宜超过100~200 。

2.3 async不确定性问题的解决
不加额外参数的async调用时让系统自行决定，是否创建新线程。

std::future result = std::async(mythread);
问题焦点在于这个写法，任务到底有没有被推迟执行。

通过wait_for返回状态来判断：

```c++
std::future_status status = result.wait_for(std::chrono::seconds(0));
	if (status == std::future_status::timeout) {
		//超时：表示线程还没有执行完
		cout << "超时了，线程还没有执行完" << endl;
	}
	else if (status == std::future_status::ready) {
		//表示线程成功放回
		cout << "线程执行成功，返回" << endl;
		cout << result.get() << endl;
	}
	else if (status == std::future_status::deferred) {
		cout << "线程延迟执行" << endl;
		cout << result.get() << endl;
	}
```



##### thread创建线程

 **① 创建一个函数，然后把该函数作为线程的入口地址**

```c++
#include <thread>
using namespace std;
void readTheval(int num) // 初始函数
{
    cout << "我是读线程" << this_thread::get_id() ;
    cout << "我读到的数据是:" << num << endl;
    return;
}
int main() {
    thread th1(readTheval, 5);   // thread 是一个类，构造，readTheval是一个可调用对象
    // 上一行创建了线程，线程执行起点（入口），已经开始执行
    th1.join();                 // join()：汇合，即阻塞，让其他线程等待子线程执行完，然后汇合
    // 上一行，其他线程阻塞到这里，等待readTheval执行完，当子线程执行完，主线程继续
    cout << "I like C++" << endl;
}
输出：
  我是读线程
  我读到的数据是5
  I like C++
```

Linux编译记得写 -pthread -std=c++11

**② 创建一个类，并编写圆括号重载函数，初始化一个该类的对象，把该对象作为线程入口地址**

```c++
class CircleReLoad
{
public:
    void operator()()  // 不能带参数，变成可调用对象
    {
        cout << "创建了一个线程" << this_thread::get_id() << endl;
        /* ...  */
        cout << "线程执行结束！" << endl;
    }
};
//main函数里的：
    CircleReLoad Acase;
    thread th1(Acase);   // 拷贝构造函数
    th1.join();     // 子线程运行完，拷贝到的构造函数被析构
```

问题：一旦调用了detach()，主线程结束后，对象Acase还在吗？如果不在，怎么进行子线程输出？

实际上，因为**右值引用**，这个对象被**复制**（浅拷贝）到线程中了，可能会在后台中析构。

**③ lambda表达式创建线程**

```c++
//main函数里
    auto OneThread = [] {
        cout << "lambda表达式创建线程" << endl;
        /* … */
        cout << this_thread::get_id() << "线程执行结束 " << endl;
    };
    thread th1(OneThread);
    th1.join();
```

**④把某个类中的某个函数作为线程的入口地址**

```c++
class Data_
{
public:
    void GetMsg(){}
    void SaveMsh(){}
};
//main函数里
    Data_ s;
    thread oneobj(&Data_::SaveMsh, &s);
    thread twoobj(&Data_::GetMsg, &s);
    oneobj.join();
    twoobj.join();
```

##### 多个线程的创建、管理

可以用vector等容器来存放

```c++
void TextThread()
{
     cout << "我是线程" << this_thread::get_id() << endl;
     /*  …  */
     cout << "线程" << this_thread::get_id() << "执行结束" << endl; 
}
 //main函数里   vector threadagg;
     for (int i = 0; i < 10; ++i)
     {
         threadagg.push_back(thread(TextThread));
     }
     for (int i = 0; i < 10; ++i)
     {
         threadagg[i].join();
     }
```

**join(), detach(), joinable()成员函数**

**join()：**
加入/汇合，起到了让**主线程等待子线程执行完毕**的作用，让子线程汇合到主线程。
 (一般来讲，主线程都是最后结束的，保证所有子线程都能正常的执行完毕)

**detach():**
 **分离**，将子线程和主线程分离开来，即子线程就**不和主线程汇合**了，主线程也不必等待子线程执行完毕
 一旦detach，与主线程里的thread对象就会**失去对这个子线程的控制**，这个子线程就会**驻留在后台运行**（当此子线程执行完后，由系统自己来清理该线程的资源）

detach可能在网络通讯中使用。

并且，当主线程结束后，可能子线程也无法继续输出到屏幕了。

> **程序崩溃**：若子线程中有**引用**或**指针**使指向主线程里的变量，且用了detach。
>
> 程序一旦使用detach()，是不能再join的。
>
> 当传入参数存在**隐式转换**的时候，也有可能出现一个问题，即主线程已经结束，传入参数的的这个变量**已经被回收**了，它才开始进行隐式转换并执行构造函数，这样就会引发错误。我们通常需要在主线程之内把这个参数对象（包括临时对象）构造出来，才能保证子线程的函数顺利执行。此时的测试结果，如果用传值，则对象的构建是在子线程中；如果构造了临时对象，因为**右值引用相当于先构造，再拷贝构造**，所以会构造两次，且这些都会在主线程中完成。
>
> 那么，想要直接传引用该怎么办呢？  使用std::ref！
>
> **（总结，如果传递int等简单参数，使用值传递，如果传递类，避免隐式类型转换，应该在创建线程时构建临时对象，且用引用传递，否则会三次构造函数）**

**joinable()**
 可以判断某thread对象是否还可以join或detach，可以就返回true，否则返回false

**条件变量condition_variable,wait(),notify_one()**

A,B两个线程
A线程往下执行是需要条件的，
B线程可以提供一个这样的条件(不一定是一对一的关系，也可能B执行了一次，A就能拿去执行好几次了，也可能需要B执行好几次后，A才满足条件执行一次)
那么当A不满足条件的时候，就不应该再跑A线程（浪费资源），而应处于等待状态，让B去跑

```c++
class Data_
{
	queue<int> MsgQueue;
	mutex mute;
	condition_variable my_con;
public:
	void GetMsg()
	{
		for (int i = 0; i < 10000; ++i)
		{
			unique_lock<mutex> obj(mute);
			my_con.wait(obj, [this]  //  lambda函数
			{
				if (MsgQueue.empty())
					return false;  //如果空了的话就直接等待，并且解锁，这
                            //个线程就不要再跑了，等到被唤醒时，再重新加锁，往下执行
				return true;  //如果没空，那就读出，继续该进程
		});
		cout << "读出" << MsgQueue.front() << endl;  //到了这里就证明，队列没空，可读消息
		MsgQueue.pop();
		}
	}
	void SaveMsh()
	{
		for (int i = 0; i < 10000; ++i)
		{
			unique_lock<mutex> obj(mute);
			MsgQueue.push(i);
			cout << "装入" << i << endl;
			my_con.notify_one();   //我已经加入元素，可以开始公平竞争（唤醒）
		}  //不一定每次notify_one()时，另一个线程都在等待，也可能人家在干别的事
	}
};
//main函数里
Data_ var;
	thread obj1(&Data_::GetMsg, &var);
	thread obj2(&Data_::SaveMsh, &var);
	obj1.join();
	obj2.join()
```

如果允许唤醒多个线程的话，可以用**notify_all()**




**B.async创建线程**

**async**是一个函数模板，用来启动异步任务，并返回**future**对象，future是一个类模板
future对象里边包含线程入口函数所返回的结果（线程返回结果），后续可通过get()成员函数得到返回值。（但get只能调用一次）
（当你希望多次调用future的成员函数get时，可改用**shared_future**类模板，当然这只是将结果存储起来，多次调用的get的值是一样的）

```c++
int TextThread(int num)
{
    cout << "我是线程" << this_thread::get_id() << endl;
    /*  …  */
    cout << "线程" << this_thread::get_id() << "执行结束" << endl;
    return num;
}
//main函数里
    future result = async(launch::async,TextThread,6);//
    cout << result.get();
```

其中：
要是launch::async省略的话，系统会把它当成**launch::async** | **launch::deferred** ，即系统**会根据当前资源状况自由调度**，如果资源不紧张一般会当成launch::async，即会立刻创建一个异步任务并开始执行，反之，则会当成是launch::deferred，会等到你调用成员函数get或wait的时候才由主线程去完成（类似于调用普通函数），当省略该参数时，可以用future_status判断系统最终有无创建线程）

**future_status**

```c++
int GetAVaule(int num)
{
    cout << "我正在执行啊！" << endl;
    cout << "我的ID是:" << this_thread::get_id() << endl;
    Sleep(3000);
    return num;
}
//main函数里
    shared_future result = async(GetAVaule, 55);
    future_status status = result.wait_for(chrono::seconds(4));//等4秒看看能不能执行完(wait_for括号里可直接写4s)
    if (status == future_status::timeout)
    {
        cout << "任务超时，还没执行完呢" << endl;
    }
    else if (status == future_status::ready)
    {
        cout << "给的时间够用，我已经准备好了" << endl;
        cout << result.get() << endl;
    }
    else if (status == future_status::deferred)
    {
        cout << "如果过你是延迟执行的参数，那就到这来" << endl;
    }
```

**packaged_task**

打包任务，把任务包装起来，是一个类模板，是一个用来包装可调用对象的可调用对象

```c++
// TextThread为上面那个函数
    packaged_task obj(TextThread);//包装
    thread th1(ref(obj),6);//开始执行线程
    th1.join();
    future result = obj.get_future();
    cout << result.get() << endl;
```

**promise**

一个类模板，能够在某个线程中给它赋值，然后可以在其它线程中，把这个值取出来为绑定为future用

```c++
void MyThread(promise& pro, int num)
{
    num *= 2;
    pro.set_value(num);
    return;
}
//main函数里
    promise my_prom;
    thread th1(MyThread, ref(my_prom), 66);
    th1.join();
    future result = my_prom.get_future();//future和promise绑定，用于获取线程返回值
    cout << result.get() << endl;
```



#### 三、共享数据问题

1、多个线程**只读，是安全稳定**的
2、多个线程同时写，或者既有读线程，也有写线程，若不加处理，就会出错

处理方法：
读的时候不能写，写的时候不能读。保护共享数据，操作时，用代码把共享数据锁住、操作数据、解锁。其他想操作共享数据的线程必须等待解锁，锁定住，操作，解锁。

有两种具体实现方法：
     ①引入**互斥量**(mutex)的概念，每次读写数据前都进行加锁保护，处理完数据后解锁
     ②引入**原子操作**的概念，定义某个变量为原子类型，每次进行一元运算符运算时，都能确保当前运算不被打断。

**互斥锁的特点：**
能对**一段代码片段**进行保护，操作**灵活**可变，但加锁解锁有一定时间开销。
**原子操作特点：**
仅适用于保护某个变量的**一元运算符运算**，但相对来讲额外的**开销小**，一般只适用于计数。

##### 互斥锁的用法

**1、mutex的成员函数lock()，unlock()**

头文件\<mutex\>

声明了一个mutex变量a后，可以用a.lock() ，a.unlock()进行加锁解锁，**加锁和解锁的次数必须相等**。加锁期间能保证当前线程的操作不会被打断，当然，锁定代码越少，执行速度越快，加锁的位置也比较考究。锁住的代码长度（行数）可以称为粒度，可以称为锁的粗和细。

**2、lock_guard**

一个用类实现的，**包装好了的锁**。如果使用，则不能再使用lock()、unlock().
声明一个mutex变量a后，可以初始化一个类模板，例：
lock_guard\<mutex\> obj(a);
obj对象在被初始化的时候自动加锁(lock)，能在离开当前作用域后，**自动析构解锁**(unlock)。
作用域可以用{ }括起来，这样决定了lock_guard的生命周期，也方便了灵活加锁。

**3、unique_lock**

也是一个用类实现的，包装好的锁，但相**比lock_guard 功能更多更灵活**，但效率和内存差一点点，没有额外参数的情况下，效果和lock_guard相同。（unique_lock \<mutex\>  obj(a);）

第二参数可以是： 
 **①adopt_lock**
（表示互斥量已被lock，无需再次加锁，就是说在用之前这个锁一定是已经被锁了的，这个参数lock_guard也是可以用的）

 **②try_to_lock**
（尝试去锁，如果没锁成功也会返回，不会卡死在那，然后可用owns_lock()得到是否上锁的信息）在用try_to_lock前，没有进行lock操作。

```c++
unique_lock<mutex> obj(mute,try_to_lock);
if (obj.owns_lock()) 
    {/*如果锁上了要怎么做…*/}
else 
    {/*没锁上也可以干别的事*/}
```

**③defer_lock**
（用一个还没上锁的mutex变量初始化一个对象，自己可以在后续代码段中的某个位置加锁）在用defer_lock前，没有进行lock操作。

```c++
  mutex a;
	unique_lock<mutex> obj(a, defer_lock);
	/* 一些代码 */
	a.lock();//也可结合条件判断语句使用a.try_lock() ，若成功锁上能返回true，否则返回false
  // 当然也不需要unlock，因为对象会帮助解锁。当然我们也能提前手动a.unlock()解锁
```

unique_lock的成员函数

```c++
void lock();
void unlock();  // lock可以比unlock数量多1或相等，在lock后一般处理共享数据，unlock后处理非共享数据
bool try_lock(); // 返回是否成功拿到锁
mutex* release(); // 返回它所管理的mutex对象指针，并释放所有权。这个unique_lock和mutex不再有关系。需要自己进行unlock();
```

unique_lock所有权的传递

```c++
std::unique_lock<std::mutex> sbguard1(my_mutex1);
std::unique_lock<std::mutex> sbguard2(std::move(sbguard1));  // 转移所有权，sbguard1失去所有权

或 return std::unique_lock<std::mutex>; // 即用其他函数构建临时对象，用移动构造函数返回这个
```



##### 死锁

有两个线程（A和B），有两个锁（c和d），A锁了c，还想要d的锁进行下一步操作，但这时B锁了d，但是想要c进行下一步操作。于是彼此互相锁死。

**死锁的一般避免方案：**

1、保证两个互斥锁的**上锁顺序一致**
2、或用**lock()这个函数模板，进行同时上锁**。（只有当每个锁都是可锁的状态，才会真正一次性上锁，用的少）

```c++
lock函数模板;
{
	std::mutex a;
	std::mutex b;
	std::lock(a, b);
	/*  ...  */
	a.unlock();
	b.unlock();
}
/*也可在lock(a,b)后用，以省去解锁步骤（adopt_lock参数表示，该锁已锁，不重复上锁，只在析构时，执行解锁）
	lock_guard<mutex> obj1(a, adopt_lock);
	lock_guard<mutex> obj2(b, adopt_lock);
*/
```

**B.原子操作**

保证**对某个变量进行一元操作符运算的时候，能够不被打断**，只需将该变量通过atomic这个类模板声明即可，效率比互斥锁高。++，–，+=，-=，&=，|=，^=

```c++
class text_class
{
public:
	atomic<int> count;
	text_class():count(0){}
	void WriteAval()
	{
		for (int i = 0; i < 100000; ++i)
		{
			++(count);
		}
	}
};
//main函数里
	text_class B;
	thread th1(&text_class::WriteAval, ref(B));
	thread th2(&text_class::WriteAval, ref(B));
	th1.join();
	th2.join();
	cout << B.count << endl;
```

如果需要拷贝，不能直接赋值，可以通过load赋值。

```c++
atomic<int> atm2(atm.load());
```

**带其它功能的互斥锁**

**1、 recursive_mutex （递归独占互斥量：可重复加锁的互斥量）**

如果某个线程需要对同一个锁进行多次加锁，那么可以用recursive_mutex代替mutex去声明互斥量，加了多少次，还是得解锁多少次

**2、timed_mutex（ 带超时的互斥量 ）**

①用**try_lock_for**成员函数，参数是等待的时间，等一段时间，若成功拿到就锁上并返回true，反之返回false

```c++
timed_mutex a;
	chrono::microseconds timeout(100);    // 微秒 100微秒 = 0.1毫秒 = 0.0001秒
	if (a.try_lock_for(timeout))//如果在规定时间内拿到了锁
	{
		/*  一波操作 */
		a.unlock();//解锁
	}
	else
	{
		//没拿到锁
	}
```

②用**try_lock_until**成员函数，参数是时间点，要是到了这个时间点，成功拿到锁，就锁上并返回true，没拿到返回false

```c++
timed_mutex a;
	chrono::microseconds timeout(100);
	if (a.try_lock_until(chrono::steady_clock::now()+timeout))//如果在规定时间内拿到了锁
	{
		/*  一波操作 */
		a.unlock();//解锁
	}
	else
	{
		//没拿到锁
	}
```


#### 四、其它

##### 单例设计模式

```c++
创建一个类;
class MyCAS {
  private:
    MyCAS() {}  // 私有化构造函数,这时不能直接用 MyCAS a1，进行创建对象
  private:
    static MyCAS* m_instance;
  public:
    static MyCAS* GetInstance() {
      if (m_instance) {
        m_instance = new MyCAS();
        static CGarRelease cl;   // 为了配合delete使用，
        							//  原因解释：它是静态对象，在程序结束后进行析构，所以也保证了delete使用。
      }
      return m_instance;
    }
    class CGarRelease {  // 嵌套类，用来释放对象
       public:
        ~CGarRelease() {
          if (MyCAS::m_instance) {
            delete MyCAS::m_instance;
            MyCAS::m_instance = NULL;
          }
        }
    }
}
```

当我们使用单例设计模式的时候，如果我们把单例类的变量的初始化放在了线程里面（一般不推荐这样做），我们就需要**确保这个初始化只会执行一次**，实现的手段有以下方式：

①双重条件判断，在高效的同时，确保初始化只能被执行一次
 比如说返回单类中某个指针，先判断是否该指针为空，若为空，则先加锁，再判断是否为空，如果为空就初始化该指针。如果不为空就返回此时的值。

②使用call_once()，能保证该函数只会被调用一次

```c++
  std::once_flag g_flag;//当然这个是放在大家都能访问到的地方
        /*  ...   */
	std::call_once(g_flag, 函数名);
```



##### 浅谈线程池

**当线程数由请求所决定，就不能简单地根据请求而创建线程**。

应该要程序启动的时候就把一定数量的线程创建好，放在池子里，需要用的时候就拿一个，用完放回去，以便下次调用，这种循环利用线程的方式就是线程池。
 一般来讲线程的创建数量，两千就是极限，一般建议200~300个，但具体情况应该具体分析，如果要调用某些api，并且api有推荐使用的线程数量，就应该根据它来。



##### windows临界区

Windows临界区，同一个线程是可以重复进入的，但是进入的次数与离开的次数必须相等。
 C++互斥量则不允许同一个线程重复加锁。

windows临界区是在windows编程中的内容，了解一下即可，效果几乎可以等同于c++11的mutex
包含#include <windows.h>
windows中的临界区同mutex一样，可以保护一个代码段。但windows的临界区可以进入多次，离开多次，但是进入的次数与离开的次数必须相等，不会引起程序报异常出错。





chrono库

chrono库主要包含了三种类型：时间间隔Duration、时钟Clocks和时间点Time point。 

https://blog.csdn.net/oncealong/article/details/28599655





智能指针：

unique_ptr构造函数已经将拷贝构造函数和拷贝赋值删除了，禁止拷贝。

如果要将unique_ptr对象传入，需要std::move(myp)。











数据库的操作？？

copy_move ?? 

死锁是什么，如何避免死锁