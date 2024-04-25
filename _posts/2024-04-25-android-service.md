---
layout: post
title: Android基础——Service
categories:
- Android
tags:
- Android
typora-root-url: ./..
image:
  path: "/assets/img/android-开始/android.jpg"
date: 2024-04-25 12:54 +0800
---
## 开始

Service用于在Android中执行一些后台任务，实现多任务或者进程间通信

Service依赖于创建时所在的进程，当进程被杀死后，该进程的所有Service均失效

使用Service不会自动创建新的线程，若需要去实现一个耗时任务，创建新线程要注意避免Service运行在主线程引起的ANR问题（应用程序无响应）

![img](/assets/img/android-service/11165797.jpg)

## 创建Service

创建Service：继承`Service`类，重写方法

```java
public class TestService extends Service {
    
    @Override
    public void onCreate() {        
        super.onCreate();
    }

    @Override
    public void onDestroy() {        
        super.onDestroy();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {        
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public IBinder onBind(Intent arg0) {        
        return null;
    }
}
```

-   `onCreate`：在Service被**创建**时调用，由系统调用
-   `onDestroy`：在Service被销毁时调用，由系统调用
-   `onStartCommand`：在Service**启动**时调用，在该方法中定义任务
-   `onBind`：返回IBinder对象，app通过IBinder对象与Service通信

`onStartCommand`方法的返回值决定了系统如何处理该Service

-   `START_STICKY`：若系统杀死Service后会重新创建，但不能接收intent
-   `START_NOT_STICKY`：系统杀死Service后不会重新创建
-   `START_REDELIVER_INTENT`：系统杀死Service后会重新创建，能够接收intent

## 注册Service

在`AndroidManifest.xml`中注册

```xml
<service android:name=".TestService"
         android:enabled="true">
    <intent-filter>  
        <action android:name="com.example.service.TEST_SERVICE"/>  
    </intent-filter> 
</service>
```

## 启动和停止Service

相关方法

-   `startService`：启动一个Service
-   `bindService`：绑定一个Service
-   `stopService`：停止一个Service

几种不同的启动方式，Service内部方法的执行顺序不同

-   调用`startService()`启动

    依次调用`onCreate()`、`onStartCommand()`，若多次调用`startService()`，则复用创建的Service对象，**重新调用`onStartCommand()`**

    通过这种方式启动Service，Service的生命周期独立于app，只能调用`stopService()`来停止

-   调用`bindService()`启动

    依次调用`onCreate()`、`onBind()`，若多次调用`bindService()`，则复用创建的Service对象，不会重新调用`onBind()`，直接将IBinder对象返回给调用端，用于与调用端通信

    调用`unbindService()`解除绑定，会调用Service的`onUnbind()`，当不存在绑定时，调用`onDestroy()`

    通过这种方式启动Service，Service的生命周期与调用端绑定，当调用端销毁，Service也停止

-   启动后绑定

    先调用`startService()`启动服务，再调用`bindService()`绑定

    Service内部触发的方法依次是`onCreate()`，`onStartCommand()`，`onBind()`，`onUnbind()`，`onRebind()`

    通过这种方式启动Service，Service的生命周期独立，通过`onBind()`返回的IBinder与app通信，调用`onUnbind`时也不会停止，可以反复绑定

ServiceConnection对象：`bindService()`的参数，可用于监听app与Service的连接情况

```java
public class MyServiceConnection extends ServiceConnection {
    //Activity与Service断开连接时回调该方法  
    @Override  
    public void onServiceDisconnected(ComponentName name) {  
        System.out.println("------Service DisConnected-------");  
    }  
          
    //Activity与Service连接成功时回调该方法  
    @Override  
    public void onServiceConnected(ComponentName name, IBinder service) { 
        System.out.println("------Service Connected-------");  
        binder = (MyBinder) service;  // onBind返回的IBinder对象
    }  
}
```

## Activity与Service通信

将Activity与Service进行绑定，使Activity可以调用Service中的方法

- 在`MyService`类中定义`MyBinder`类，继承`Binder`类，在该类中提供执行的方法
- 在`MyService`类中创建`MyBinder`类的实例，在`onBind()`中返回该对象
- 在`MainActivity`中创建`ServiceConnection`实现类对象，重写方法
- 通过Intent将Activity与Service绑定，调用`bindService()`，传入intent和connection对象和值`Service.BIND_AUTO_CREATE`，表示绑定后自动创建Service，其中会执行MyService的`onCreate()`，不执行`onStartCommand()`

`MyService`实现`Service`类

```java
public class TestService extends Service {  
    private final String TAG = "TestService";  
    private int count;  
    private boolean quit;  
      
    //定义onBinder方法所返回的对象  
    private MyBinder binder = new MyBinder();  
    
    public class MyBinder extends Binder {  
        public int getCount() {  
            return count;  
        }  
    }  
      
    //必须实现的方法,绑定改Service时回调该方法  
    @Override  
    public IBinder onBind(Intent intent) {  
        Log.i(TAG, "onBind方法被调用!");  
        return binder;  
    }  
  
    //Service被创建时回调  
    @Override  
    public void onCreate() {  
        super.onCreate();  
        Log.i(TAG, "onCreate方法被调用!");  
        //创建一个线程动态地修改count的值  
        new Thread() {  
            public void run() {  
                while(!quit) {  
                    try {  
                        Thread.sleep(1000);  
                    } catch(InterruptedException e) {
                        e.printStackTrace();
                    }  
                    count++;  
                }  
            };  
        }.start();  
    }  
      
    //Service断开连接时回调  
    @Override  
    public boolean onUnbind(Intent intent) {  
        Log.i(TAG, "onUnbind方法被调用!");  
        return true;  
    }  
      
    //Service被关闭前回调  
    @Override  
    public void onDestroy() {  
        super.onDestroy();  
        this.quit = true;  
        Log.i(TAG, "onDestroyed方法被调用!");  
    }  
      
    @Override  
    public void onRebind(Intent intent) {  
        Log.i(TAG, "onRebind方法被调用!");  
        super.onRebind(intent);  
    }  
} 
```

在Activity中使用Service

```java
public class MainActivity extends Activity {  
    // ...
      
    // IBinder引用
    MyBinder binder;  
    
    // ServiceConnection实现
    private ServiceConnection conn = new ServiceConnection() {  
          
        //Activity与Service断开连接时回调该方法  
        @Override  
        public void onServiceDisconnected(ComponentName name) {  
            System.out.println("------Service DisConnected-------");  
        }  
          
        //Activity与Service连接成功时回调该方法  
        @Override  
        public void onServiceConnected(ComponentName name, IBinder service) {  
            System.out.println("------Service Connected-------");  
            binder = (TestService2.MyBinder) service;  
        }  
    };  
      
    @Override  
    protected void onCreate(Bundle savedInstanceState) {  
        super.onCreate(savedInstanceState);  
        // ...
        
        // 创建intent
        final Intent intent = new Intent();  
        intent.setAction("com.example.service.TEST_SERVICE");  
        
        // 绑定Service
        btnbind.setOnClickListener(v -> {
            bindService(intent, conn, Service.BIND_AUTO_CREATE);
        });
        
        // 解除绑定
        btncancel.setOnClickListener(v -> {
            unbindService(conn);
        });  
          
        btnstatus.setOnClickListener(v- > {
            // 调用MyBinder方法，使用前最好判空
            int count = binder.getCount()
        });  
    }  
}
```

## IntentService

使用Service进行耗时操作时，容易引发ANR，这是由于Service不会创建线程，它与app处于同一个进程中

使用IntentService可以解决该问题，IntentService中存在一个任务队列，将请求的Intent放入队列中，在后台线程进行处理

继承`IntentService`类实现相应方法

```java
public class TestService extends IntentService {  
    private final String TAG = "hehe";  
    
    //必须实现父类的构造方法  
    public TestService() {  
        super("TestService");  
    }  
  
    //必须重写的核心方法，该方法在后台线程中调用
    @Override  
    protected void onHandleIntent(Intent intent) {
        
        //Intent是从Activity发过来的，携带识别参数，根据参数不同执行不同的任务  
        String action = intent.getExtras().getString("param");  
        if(action.equals("s1")) {
            Log.i(TAG,"启动service1");
        } else if (action.equals("s2")) {
            Log.i(TAG,"启动service2");
        } else if (action.equals("s3")) {
            Log.i(TAG,"启动service3");
        }
          
        //让服务休眠2秒  
        try {  
            Thread.sleep(2000);  
        } catch(InterruptedException e) { 
            e.printStackTrace();
        }          
    }  
  
    @Override  
    public IBinder onBind(Intent intent) {  
        Log.i(TAG,"onBind");  
        return super.onBind(intent);  
    }  
  
    @Override  
    public void onCreate() {  
        Log.i(TAG,"onCreate");  
        super.onCreate();  
    }  
  
    @Override  
    public int onStartCommand(Intent intent, int flags, int startId) {  
        Log.i(TAG,"onStartCommand");  
        return super.onStartCommand(intent, flags, startId);  
    }  
  
  
    @Override  
    public void setIntentRedelivery(boolean enabled) {  
        super.setIntentRedelivery(enabled);  
        Log.i(TAG,"setIntentRedelivery");  
    }  
      
    @Override  
    public void onDestroy() {  
        Log.i(TAG,"onDestroy");  
        super.onDestroy();  
    }
}
```



