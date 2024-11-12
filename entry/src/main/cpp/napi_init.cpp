#include "napi/native_api.h"
#include <cassert>
#include <map>
#include <string>
#include <utility>
#define LOG_DOMAIN 0x3200 // 全局domain宏，标识业务领域
#define LOG_TAG "MY_TAG" // 全局tag宏，标识模块日志tag
#include "hilog/log.h"
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
        {"getSystemCap", nullptr, NAPI_Global_getSystemCap, nullptr, nullptr, nullptr, napi_default, nullptr}};
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
