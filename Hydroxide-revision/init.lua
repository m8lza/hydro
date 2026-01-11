-- [[ BugHunt Pro - Solara Optimized Init ]] --
local environment = getgenv()

-- التأكد من أن oh غير معرف مسبقاً لمنع التداخل
if oh then
    oh.Exit()
end

local web = true
local user = "m8lza" -- تم تعديل اسم المستخدم لـ GitHub الخاص بك
local repo = "BugHuntTool" -- تأكد أن هذا هو اسم المستودع لديك
local branch = "main"
local importCache = {}

local function hasMethods(methods)
    for name in pairs(methods) do
        if not environment[name] then
            return false
        end
    end
    return true
end

local function useMethods(module)
    if type(module) ~= "table" then return end
    for name, method in pairs(module) do
        if method then
            environment[name] = method
        end
    end
end

-- تعريف الدوال المتوافقة مع Solara لتجنب أخطاء "Exploit not supported"
local globalMethods = {
    checkCaller = checkcaller,
    newCClosure = newcclosure,
    hookFunction = hookfunction or detour_function,
    getGc = getgc or get_gc_objects,
    getInfo = debug.getinfo or getinfo,
    getSenv = getsenv,
    getMenv = getmenv or getsenv,
    getConnections = get_signal_cons or getconnections,
    getScriptClosure = getscriptclosure or get_script_function,
    getNamecallMethod = getnamecallmethod or get_namecall_method,
    getConstants = debug.getconstants or getconstants,
    getUpvalues = debug.getupvalues or getupvalues,
    getProtos = debug.getprotos or getprotos,
    getConstant = debug.getconstant or getconstant,
    getUpvalue = debug.getupvalue or getupvalue,
    getMetatable = getrawmetatable or debug.getmetatable,
    setClipboard = setclipboard or writeclipboard,
    setReadOnly = setreadonly or function(t, r) 
        if setrawmetatable then 
            local m = getrawmetatable(t) 
            if m then m.__readonly = r end 
        end 
    end,
    isLClosure = islclosure or function(f) return type(f) == "function" end,
}

useMethods(globalMethods)

-- دالة الاستيراد (Import) المعدلة لتقرأ من روابطك مباشرة
function environment.import(asset)
    if importCache[asset] then
        return unpack(importCache[asset])
    end

    -- تعديل الرابط ليشير إلى مجلدك في GitHub
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/bughunttool/%s.lua", user, repo, branch, asset)
    
    local success, content = pcall(game.HttpGet, game, url)
    
    if success and content and content ~= "404: Not Found" then
        local func, err = loadstring(content, asset .. '.lua')
        if func then
            local result = { func() }
            importCache[asset] = result
            return unpack(result)
        else
            warn("<BugHunt> Error in " .. asset .. ": " .. tostring(err))
        end
    else
        warn("<BugHunt> Failed to download: " .. asset .. " from " .. url)
    end
end

-- إعداد كائن OH الأساسي
environment.oh = {
    Events = {},
    Hooks = {},
    Cache = importCache,
    Methods = globalMethods,
    Exit = function()
        print("BugHunt System Exited")
    end
}

-- تحميل المكتبات المساعدة (تأكد من رفعها في مجلد bughunttool)
pcall(function()
    useMethods(import("methods/string"))
    useMethods(import("methods/table"))
    useMethods(import("methods/environment"))
end)

-- تشغيل الواجهة (تأكد من وجود ملف ui/main.lua أو MainInterface.lua)
print("BugHunt Pro V6 Loaded for " .. user)
-- import("ui/main")
