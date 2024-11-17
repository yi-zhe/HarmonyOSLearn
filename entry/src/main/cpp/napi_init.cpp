#include "napi/native_api.h"
#include <cassert>
#include <deque>
#include <map>
#include <mutex>
#include <string>
#include <utility>
#define LOG_DOMAIN 0x3200 // 全局domain宏，标识业务领域
#define LOG_TAG "MY_TAG" // 全局tag宏，标识模块日志tag
#include "hilog/log.h"

#include <rawfile/raw_file_manager.h>
#include "ark_runtime/jsvm.h"
using namespace std;

static napi_value Add(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    return sum;
}
std::map<std::string, int> testmap;
static napi_value NAPI_Global_mapDemo(napi_env env, napi_callback_info info) {
    size_t requireArgc = 2;
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    char str1[1024];
    size_t str1_len;
    napi_get_value_string_utf8(env, args[0], str1, 100, &str1_len);
    int num;
    napi_get_value_int32(env, args[1], &num);
    std::pair<std::string, int> res = std::make_pair(str1, num);
    testmap.insert(res);
    for (auto e : testmap) {
        OH_LOG_ERROR(LOG_APP, "key is: %{public}s, value is  %{public}d", (e.first).c_str(), e.second);
    }
    return nullptr;
}

// 在C++创建buffer数据 char* 指针
static napi_value TestBuffer(napi_env env, napi_callback_info) {
    size_t length = 100;
    char *data = nullptr;
    napi_value result = nullptr;
    napi_create_buffer(env, length, reinterpret_cast<void **>(&data), &result);

    char buf[50] = {0};
    for (int i = 0; i < 50; i++) {
        buf[i] = i + 2;
    }
    napi_create_buffer_copy(env, 50, buf, reinterpret_cast<void **>(&data), &result);
    return result;
}

static napi_value Cal(napi_env env, napi_callback_info info) {
    size_t argc = 4;
    napi_value args[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    // 构造类实例
    napi_value demo;
    napi_create_object(env, &demo);
    napi_coerce_to_object(env, args[2], &demo);

    bool flag;
    napi_get_value_bool(env, args[3], &flag);

    // 获取类实例的add，sub函数
    napi_value add, sub, num;
    napi_get_named_property(env, demo, "add", &add);
    napi_get_named_property(env, demo, "sub", &sub);

    // 调用ArkTS函数
    napi_value result;
    if (flag) {
        napi_call_function(env, nullptr, add, 2, args, &result);
    } else {
        napi_call_function(env, nullptr, sub, 2, args, &result);
    }

    return result;
}

static napi_value ModifyObject(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value obj = args[0];

    napi_value obj1;
    napi_value hello1;
    napi_value arr1;
    napi_value typedArray1;

    napi_get_named_property(env, obj, "obj", &obj1);
    char *buf = "this is modified";
    napi_value str1;
    napi_create_string_utf8(env, buf, NAPI_AUTO_LENGTH, &str1);
    napi_set_named_property(env, obj1, "str", str1);
    napi_set_named_property(env, obj, "obj", obj1);

    napi_create_string_utf8(env, "world0", NAPI_AUTO_LENGTH, &hello1);
    napi_set_named_property(env, obj, "hello", hello1);

    napi_get_named_property(env, obj, "arr", &arr1);
    uint32_t arrLen;
    napi_get_array_length(env, arr1, &arrLen);
    for (int i = 0; i < arrLen; i++) {
        napi_value tmp;
        napi_create_uint32(env, i, &tmp);
        napi_set_element(env, arr1, i, tmp);
    }
    napi_delete_element(env, arr1, 2, nullptr);


    napi_get_named_property(env, obj, "typedArray", &typedArray1);
    bool is_typedArray;
    if (napi_ok != napi_is_typedarray(env, typedArray1, &is_typedArray)) {
        return nullptr;
    }
    napi_typedarray_type type;
    napi_value input_buffer;
    size_t length;
    size_t byte_offset;
    napi_get_typedarray_info(env, typedArray1, &type, &length, nullptr, &input_buffer, &byte_offset);
    // 获取 input_buffer 的基础数据缓冲区 data，和基础数据缓冲区的长度 byte_length。
    void *data;
    size_t byte_length;
    napi_get_arraybuffer_info(env, input_buffer, &data, &byte_length);
    // 创建新的ArrayBuffer，&output_ptr 指向 ArrayBuffer 的底层数据缓冲区的指针
    napi_value output_buffer;
    void *output_prt = nullptr;
    napi_create_arraybuffer(env, byte_length, &output_prt, &output_buffer);
    // 使用 output_buffer 创建 typedarray
    napi_value output_array;
    napi_create_typedarray(env, type, length, output_buffer, byte_offset, &output_array);
    // data 是由连续的内存位置组成，reinterpret_cast<uint8_t *>(data)  表示其第一个元素的内存地址。
    // data 是旧的 arraybuffer 数据指针
    uint8_t *input_bytes = reinterpret_cast<uint8_t *>(data) + byte_offset;
    // 把 output_ptr 指针赋值给 output_bytes
    // output_ptr 是新的 arraybuffer 数据指针
    uint8_t *output_bytes = reinterpret_cast<uint8_t *>(output_prt);
    for (int i = 0; i < length; i++) {
        // 将旧 arraybuffer 数据每一个元素乘 2，赋值给新 arraybuffer 数据
        output_bytes[i] = input_bytes[i] * 2;
    }
    // 将新 typedArray 赋值给 obj['typedArray']
    napi_set_named_property(env, obj, "typedArray", output_array);
    return obj;
}


struct CallbackData {
    napi_async_work asyncWork = nullptr;
    napi_deferred deferred = nullptr;
    napi_ref callback = nullptr;
    double args = 0;
    double result = 0;
};
//定义异步任务的第一个回调函数，该函数在工作线程中执行，处理具体的业务逻辑。
static void ExecuteCB(napi_env env, void *data)
{
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
    callbackData->result = callbackData->args;
}
//定义异步任务的第二个回调函数，该函数在主线程执行，将结果传递给ArkTS侧。
static void CompleteCB(napi_env env, napi_status status, void *data)
{
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
    napi_value result = nullptr;
    napi_create_double(env, callbackData->result, &result);
    if (callbackData->result > 0) {
        napi_resolve_deferred(env, callbackData->deferred, result);
    } else {
        napi_reject_deferred(env, callbackData->deferred, result);
    }

    napi_delete_async_work(env, callbackData->asyncWork);
    delete callbackData;
}


static napi_value AsyncWork(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value promise = nullptr;
    napi_deferred deferred = nullptr;
    napi_create_promise(env, &deferred, &promise);

    auto callbackData = new CallbackData();
    callbackData->deferred = deferred;
    napi_get_value_double(env, args[0], &callbackData->args);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "AsyncCallback", NAPI_AUTO_LENGTH, &resourceName);
    // 创建异步任务
    napi_create_async_work(env, nullptr, resourceName, ExecuteCB, CompleteCB, callbackData, &callbackData->asyncWork);
    // 将异步任务加入队列
    napi_queue_async_work(env, callbackData->asyncWork);

    return promise;
}


static napi_value NAPI_Global_getLastErrorInfo(napi_env env, napi_callback_info info) {
    // 获取输入参数（这里以字符串message作为参数传入）
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    // 将传入的字符串参数以napi_get_value_int32取出，主动制造错误
    int32_t value = 0;
    napi_status status = napi_get_value_int32(env, args[0], &value);
    // 接口使用错误，故返回值不为napi_ok
    assert(status != napi_ok);
    // 调用接口napi_get_last_error_info获取最后一次错误信息
    const napi_extended_error_info *errorInfo;
    napi_get_last_error_info(env, &errorInfo);
    // 取出错误码与接口调用错误后其返回值作比较
    assert(errorInfo->error_code == status);
    // 取出错误消息作为返回值带出去打印
    napi_value result = nullptr;
    napi_create_string_utf8(env, errorInfo->error_message, NAPI_AUTO_LENGTH, &result);
    return result;
}
static napi_value NAPI_Global_getSystemCap(napi_env env, napi_callback_info info) {
    // 获取arkts侧的系统库路径 
    char path[64] = "@ohos.display"; 
    size_t typeLen = 0; 
    napi_value string; 
    napi_create_string_utf8(env, path, typeLen, &string); 
    // 加载系统库 
    napi_value sysModule; 
    napi_load_module(env, path, &sysModule); 
    // 获取系统库中的"getDefaultDisplaySync"方法 
    napi_value func = nullptr; 
    napi_get_named_property(env, sysModule, "getDefaultDisplaySync", &func); 
    napi_value funcResult; 
    napi_call_function(env, sysModule, func, 0, nullptr, &funcResult); 
    napi_value widthValue = nullptr; 
    napi_get_named_property(env, funcResult, "width", &widthValue); 
    double width; 
    napi_get_value_double(env, widthValue, &width); 
    OH_LOG_INFO(LOG_APP, "width: %{public}f", width); 
    napi_value heightValue = nullptr; 
    napi_get_named_property(env, funcResult, "height", &heightValue); 
    double height; 
    napi_get_value_double(env, heightValue, &height); 
    OH_LOG_INFO(LOG_APP, "height: %{public}f", height); 
    // 业务拿到width 和 height，可以进一步处理具体业务逻辑 
    napi_value result = nullptr;
    napi_create_string_utf8(env, "TEST ok", NAPI_AUTO_LENGTH, &result);
    return result;
}


static map<int, JSVM_VM *> g_vmMap;
static map<int, JSVM_VMScope> g_vmScopeMap;
static map<int, JSVM_Env *> g_envMap;
static map<int, napi_env> g_napiEnvMap;
static map<int, JSVM_EnvScope> g_envScopeMap;
static map<int, napi_ref> g_callBackMap;
static map<int, JSVM_CallbackStruct *> g_callBackStructMap;
static uint32_t ENVTAG_NUMBER = 0;
static std::mutex envMapLock;
static std::mutex mutexLock;
static int aa = 0;

// 代表了 队列中的task
class Task {
public:
    virtual ~Task() = default;
    virtual void Run() = 0;
};

static map<int, deque<Task *>> g_taskQueueMap;

std::string napiValueToString(napi_env env, napi_value nValue) {
    size_t buffLen = 0;
    napi_get_value_string_utf8(env, nValue, nullptr, 0, &buffLen);
    char buffer[buffLen + 1];
    napi_get_value_string_utf8(env, nValue, buffer, buffLen + 1, &buffLen);
    return buffer;
}

static std::string fromOHStringValue(JSVM_Env &env, JSVM_Value &value) {
    size_t size;
    JSVM_Status status;
    status = OH_JSVM_GetValueStringUtf8(env, value, nullptr, 0, &size);
    char resultStr[size + 1];
    status = OH_JSVM_GetValueStringUtf8(env, value, resultStr, size + 1, &size);
    return resultStr;
}


static JSVM_Value Consoleinfo(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 1;
    JSVM_Value args[1];
    char log[256] = "";
    size_t log_length;
    OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL);

    OH_JSVM_GetValueStringUtf8(env, args[0], log, 255, &log_length);
    log[255] = 0;
    OH_LOG_INFO(LOG_APP, "JSVM API TEST: %{public}s", log);
    return nullptr;
}

static JSVM_Value Add(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 2;
    JSVM_Value args[2];
    OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL);
    double num1, num2;
    OH_JSVM_GetValueDouble(env, args[0], &num1);
    OH_JSVM_GetValueDouble(env, args[1], &num2);
    JSVM_Value sum = nullptr;
    OH_JSVM_CreateDouble(env, num1 + num2, &sum);
    return sum;
}

static JSVM_Value AssertEqual(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 2;
    JSVM_Value args[2];
    OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL);

    bool isStrictEquals = false;
    OH_JSVM_StrictEquals(env, args[0], args[1], &isStrictEquals);

    if (isStrictEquals) {
        OH_LOG_INFO(LOG_APP, "JSVM API TEST RESULT: PASS");
    } else {
        OH_LOG_INFO(LOG_APP, "JSVM API TEST RESULT: FAILED");
    }
    return nullptr;
}


static JSVM_Value OnJSResultCallback(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 3;
    JSVM_Value args[3];
    OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL);
    int callId = 0;
    OH_JSVM_GetValueInt32(env, args[0], &callId);
    napi_value callArgs[2] = {nullptr, nullptr};
    size_t size;
    size_t size1;

    OH_JSVM_GetValueStringUtf8(env, args[1], nullptr, 0, &size);
    char Str1[size + 1];
    OH_JSVM_GetValueStringUtf8(env, args[1], Str1, size + 1, &size);

    OH_JSVM_GetValueStringUtf8(env, args[2], nullptr, 0, &size1);
    char Str2[size1 + 1];
    OH_JSVM_GetValueStringUtf8(env, args[2], Str2, size1 + 1, &size1);

    napi_create_string_utf8(g_napiEnvMap[callId], Str1, size + 1, &callArgs[0]);
    napi_create_string_utf8(g_napiEnvMap[callId], Str2, size1 + 1, &callArgs[1]);
    napi_value callback = nullptr;
    // 通过callId获取在创建当前JSVM环境时传入的TS回调方法
    napi_get_reference_value(g_napiEnvMap[callId], g_callBackMap[callId], &callback);
    napi_value ret;
    // 执行TS回调方法
    napi_call_function(g_napiEnvMap[callId], nullptr, callback, 2, callArgs, &ret);
    char retStr[256];
    napi_get_value_string_utf8(g_napiEnvMap[callId], ret, retStr, 256, &size);

    JSVM_Value returnVal;
    OH_JSVM_CreateStringUtf8(env, retStr, JSVM_AUTO_LENGTH, &returnVal);
    return returnVal;
}
// 自定义创建Promise方法用以在JS代码中创建Promise
static JSVM_Value CreatePromise(JSVM_Env env, JSVM_CallbackInfo info) {
    OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise start");
    int envID = 0;
    // 通过当前env获取envID
    for (auto it = g_envMap.begin(); it != g_envMap.end(); ++it) {
        if (*it->second == env) {
            envID = it->first;
            break;
        }
    }
    if (envID == -1) {
        OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise envID faild");
        return nullptr;
    }
    
    JSVM_Value promise;
    JSVM_Deferred deferred;
    OH_JSVM_CreatePromise(env, &deferred, &promise);
      class ReadTask : public Task {
    public:
        ReadTask(JSVM_Env env, JSVM_Deferred deferred, int envNum) : env_(env), envID_(envNum), deferred_(deferred) {}
        void Run() override {
            //string str = "TEST RUN OH_JSVM_ResolveDeferred";
            int envID = 0;
            for (auto it = g_envMap.begin(); it != g_envMap.end(); ++it) {
                if (*it->second == env_) {
                    envID = it->first;
                    break;
                }
            }
            OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise %{public}d", envID);
            JSVM_Value result;
            OH_JSVM_CreateInt32(env_, envID, &result);
            OH_JSVM_ResolveDeferred(env_, deferred_, result);
        }
    private:
        JSVM_Env env_;
        int envID_;
        JSVM_Deferred deferred_;
    };
    g_taskQueueMap[envID].push_back(new ReadTask(env, deferred, envID));
    OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise end");
    return promise;
    
}

// 创建JS上下文
static void CreateArkJSContext() {
    JSVM_Status status;
    JSVM_InitOptions init_options;
    memset(&init_options, 0, sizeof(init_options));
    if (aa == 0) {
        OH_JSVM_Init(&init_options);
        aa++;
    }
    // 虚拟机实例
    g_vmMap[ENVTAG_NUMBER] = new JSVM_VM;
    JSVM_VMScope vmScope;
    g_vmScopeMap[ENVTAG_NUMBER] = vmScope;
    JSVM_CreateVMOptions options;
    memset(&options, 0, sizeof(options));
    status = OH_JSVM_CreateVM(&options, g_vmMap[ENVTAG_NUMBER]);
    status = OH_JSVM_OpenVMScope(*g_vmMap[ENVTAG_NUMBER], &g_vmScopeMap[ENVTAG_NUMBER]);

    // 新环境
    g_envMap[ENVTAG_NUMBER] = new JSVM_Env;
    g_callBackStructMap[ENVTAG_NUMBER] = new JSVM_CallbackStruct[5]; // 主要是为了调用C++的函数
    for (int i = 0; i < 5; i++) {
        g_callBackStructMap[ENVTAG_NUMBER][i].data = nullptr;
    }
    g_callBackStructMap[ENVTAG_NUMBER][0].callback = Consoleinfo;
    g_callBackStructMap[ENVTAG_NUMBER][1].callback = Add;
    g_callBackStructMap[ENVTAG_NUMBER][2].callback = AssertEqual;
    g_callBackStructMap[ENVTAG_NUMBER][3].callback = OnJSResultCallback;
    g_callBackStructMap[ENVTAG_NUMBER][4].callback = CreatePromise;

    // napi 当中 绑定关系
    JSVM_PropertyDescriptor descriptors[] = {
        {"consoleinfo", NULL, &g_callBackStructMap[ENVTAG_NUMBER][0], NULL, NULL, NULL, JSVM_DEFAULT},
        {"add", NULL, &g_callBackStructMap[ENVTAG_NUMBER][1], NULL, NULL, NULL, JSVM_DEFAULT},
        {"assertEqual", NULL, &g_callBackStructMap[ENVTAG_NUMBER][2], NULL, NULL, NULL, JSVM_DEFAULT},
        {"onJSResultCallback", NULL, &g_callBackStructMap[ENVTAG_NUMBER][3], NULL, NULL, NULL, JSVM_DEFAULT},
        {"createPromise", NULL, &g_callBackStructMap[ENVTAG_NUMBER][4], NULL, NULL, NULL, JSVM_DEFAULT},
    };
    status = OH_JSVM_CreateEnv(*g_vmMap[ENVTAG_NUMBER], sizeof(descriptors) / sizeof(descriptors[0]), descriptors,
                               g_envMap[ENVTAG_NUMBER]);
    JSVM_EnvScope envScope;
    g_envScopeMap[ENVTAG_NUMBER] = envScope;
    status = OH_JSVM_OpenEnvScope(*g_envMap[ENVTAG_NUMBER], &g_envScopeMap[ENVTAG_NUMBER]);
}

/***
 *
 * @param env 上下文
 * @param info 拿参数
 * @return
 */
static napi_value CreateJsCore(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value argv[1];
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (argc < 1) {
        OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore the number of params must be one");
        return nullptr;
    }
    g_napiEnvMap[ENVTAG_NUMBER] = env;
    g_taskQueueMap[ENVTAG_NUMBER] = deque<Task *>{};
    // 将TS侧传入的回调函数与env对应存储方便后续调用
    napi_ref callFun;
    napi_create_reference(env, argv[0], 1, &callFun);
    g_callBackMap[ENVTAG_NUMBER] = callFun;
    napi_value coreID = 0;
    {
        std::lock_guard<std::mutex> lock_guard(envMapLock);
        CreateArkJSContext();
        napi_create_uint32(env, ENVTAG_NUMBER, &coreID);
        ENVTAG_NUMBER++;
    }
    OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore END");
    return coreID;
}

// 编译 执行 获取结果
static napi_value EvaluateJS(napi_env env, napi_callback_info info) {
    OH_LOG_ERROR(LOG_APP, "JSVM EvalUateJS START");
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    uint32_t envId;
    napi_status status = napi_get_value_uint32(env, args[0], &envId);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "EvalUateJS first param should be number");
        return nullptr;
    }
    if (g_envMap.count(envId) == 0 || g_envMap[envId] == nullptr) {
        OH_LOG_ERROR(LOG_APP, "EvalUateJS env is null");
        return nullptr;
    }
    std::string dataStr = napiValueToString(env, args[1]);
    napi_value res = nullptr; // 是NAPi的数据 给TS用的
    std::lock_guard<std::mutex> lock_guard(mutexLock);
    {
        // 打开HandleScope 注意一定要有
        JSVM_HandleScope handlescope;
        OH_JSVM_OpenHandleScope(*g_envMap[envId], &handlescope);
        // Compile
        JSVM_Value sourcecodevalue;
        OH_JSVM_CreateStringUtf8(*g_envMap[envId], dataStr.c_str(), dataStr.size(), &sourcecodevalue);
        JSVM_Script script;
        OH_JSVM_CompileScript(*g_envMap[envId], sourcecodevalue, nullptr, 0, true, nullptr, &script);
        // run
        JSVM_Value result;
        OH_JSVM_RunScript(*g_envMap[envId], script, &result); // 放到队列
        // 判断JS运行的结
        JSVM_ValueType type;
        OH_JSVM_Typeof(*g_envMap[envId], result, &type);
        OH_LOG_INFO(LOG_APP, "JSVM API TEST type: %{public}d", type);
        // 执行任务
        while (!g_taskQueueMap[envId].empty()) {
            auto task = g_taskQueueMap[envId].front();
            g_taskQueueMap[envId].pop_front();
            task->Run();
            delete task;
        }

        if (type == JSVM_STRING) {
            std::string stdResult = fromOHStringValue(*g_envMap[envId], result);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        } else if (type == JSVM_BOOLEAN) {
            bool ret = false;
            std::string stdResult;
            OH_JSVM_GetValueBool(*g_envMap[envId], result, &ret);
            ret ? stdResult = "true" : stdResult = "false";
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        } else if (type == JSVM_NUMBER) {
            int32_t num;
            OH_JSVM_GetValueInt32(*g_envMap[envId], result, &num);
            std::string stdResult = std::to_string(num);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        } else if (type == JSVM_OBJECT) {
            JSVM_Value objResult;
            OH_JSVM_JsonStringify(*g_envMap[envId], result, &objResult);
            std::string stdResult = fromOHStringValue(*g_envMap[envId], objResult);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        }

        bool aal = false;
        OH_JSVM_PumpMessageLoop(*g_vmMap[envId], &aal);
        OH_JSVM_PerformMicrotaskCheckpoint(*g_vmMap[envId]);
        OH_JSVM_CloseHandleScope(*g_envMap[envId], handlescope);
    }
    OH_LOG_ERROR(LOG_APP, "JSVM EvalUateJS END");
    return res;
}

// 对外提供释放JSVM环境接口，通过envId释放对应环境
static napi_value ReleaseJsCore(napi_env env1, napi_callback_info info) {
    OH_LOG_ERROR(LOG_APP, "JSVM ReleaseJsCore START");
    size_t argc = 1;
    napi_value argv[1];
    napi_get_cb_info(env1, info, &argc, argv, nullptr, nullptr);
    if (argc < 1) {
        OH_LOG_ERROR(LOG_APP, "JSVM ReleaseJsCore the number of params must be one");
        return nullptr;
    }

    uint32_t coreEnvId;
    napi_status status = napi_get_value_uint32(env1, argv[0], &coreEnvId);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore napi_get_value_uint32 faild");
        return nullptr;
    }
    if (g_envMap.count(coreEnvId) == 0) {
        OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore not has env ");
        return nullptr;
    }
    if (g_envMap[coreEnvId] != nullptr) {
        std::lock_guard<std::mutex> lock_guard(envMapLock);
        OH_JSVM_CloseEnvScope(*g_envMap[coreEnvId], g_envScopeMap[coreEnvId]);
        g_envScopeMap.erase(coreEnvId);
        OH_JSVM_DestroyEnv(*g_envMap[coreEnvId]);
        g_envMap[coreEnvId] = nullptr;
        g_envMap.erase(coreEnvId);
        OH_JSVM_CloseVMScope(*g_vmMap[coreEnvId], g_vmScopeMap[coreEnvId]);
        g_vmScopeMap.erase(coreEnvId);
        OH_JSVM_DestroyVM(*g_vmMap[coreEnvId]);
        g_vmMap[coreEnvId] = nullptr;
        g_vmMap.erase(coreEnvId);
        delete[] g_callBackStructMap[coreEnvId];
        g_callBackStructMap[coreEnvId] = nullptr;
        g_callBackStructMap.erase(coreEnvId);
        napi_delete_reference(env1, g_callBackMap[coreEnvId]);
        g_callBackMap.erase(coreEnvId);
        g_taskQueueMap.erase(coreEnvId);
    }
    OH_LOG_ERROR(LOG_APP, "JSVM ReleaseJsCore END");
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"mapDemo", nullptr, NAPI_Global_mapDemo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"cal", nullptr, Cal, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"modifyObject", nullptr, ModifyObject, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"asyncWork", nullptr, AsyncWork, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testBuffer", nullptr, TestBuffer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getLastErrorInfo", nullptr, NAPI_Global_getLastErrorInfo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSystemCap", nullptr, NAPI_Global_getSystemCap, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createJsCore", nullptr, CreateJsCore, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"evaluateJS", nullptr, EvaluateJS, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"releaseJsCore", nullptr, ReleaseJsCore, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
