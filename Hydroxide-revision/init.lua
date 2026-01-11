-- [[ BugHunt Pro - Hydroxide Based Init for Solara ]] --
local environment = getgenv()

-- منع التداخل عند إعادة التشغيل
if oh then 
    pcall(oh.Exit) 
end

local user = "m8lza" -- حسابك في GitHub
local repo = "BugHuntTool" -- اسم المستودع
local branch = "main" -- الفرع الأساسي
local importCache = {}

-- 1. تعريف الدوال الأساسية وتجنب أخطاء الدعم (Solara Fix)
local globalMethods = {
    checkCaller = checkcaller or function() return false end,
    newCClosure = newcclosure or function(f) return f end,
    hookFunction = hookfunction or detour_function,
    getGc = getgc or get_gc_objects or function() return {} end,
    getInfo = debug.getinfo or getinfo,
    getSenv = getsenv or function() return {} end,
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
    setReadOnly = setreadonly or make_readonly or function(t, b) 
        local mt = getrawmetatable(t)
        if mt then mt.__readonly = b end
    end,
    isLClosure = islclosure or function(f) return type(f) == "function" end,
    readFile = readfile,
    writeFile = writefile,
    makeFolder = makefolder,
    isFolder = isfolder,
    isFile = isfile,
}

-- 2. دالة الاستيراد الذكية (Smart Import) من GitHub الخاص بك
function environment.import(asset)
    if importCache[asset] then
        return unpack(importCache[asset])
    end

    -- رابط ملفاتك داخل مجلد bughunttool
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/bughunttool/%s.lua", user, repo, branch, asset)
    
    local success, content = pcall(game.HttpGet, game, url)
    
    if success and content and not content:find("404") then
        local func, err = loadstring(content, asset .. '.lua')
        if func then
            local result = { func() }
            importCache[asset] = result
            return unpack(result)
        else
            warn("<BugHunt> Error parsing " .. asset .. ": " .. tostring(err))
        end
    else
        warn("<BugHunt> Resource not found: " .. asset)
    end
end

-- 3. بناء كائن النظام (oh)
environment.oh = {
    Events = {},
    Hooks = {},
    Cache = importCache,
    Methods = globalMethods,
    Constants = {
        -- أيقونات وألوان الواجهة (مستمدة من كودك الأصلي)
        Types = { ["nil"] = "rbxassetid://4800232219", table = "rbxassetid://4666594276" },
        Syntax = { string = Color3.fromRGB(225, 150, 85), number = Color3.fromRGB(170, 225, 127) }
    },
    Exit = function()
        for _, event in pairs(environment.oh.Events) do pcall(event.Disconnect, event) end
        print("BugHunt System Stopped.")
    end
}

-- 4. تحميل الدوال المساعدة (Methods) من مستودعك
-- ملاحظة: تأكد أن هذه الملفات موجودة في GitHub بنفس المسار
pcall(function()
    environment.import("methods/string")
    environment.import("methods/table")
    environment.import("methods/environment")
end)

-- دمج الدوال العالمية في البيئة
for name, method in pairs(globalMethods) do
    environment[name] = method
end

print("--------------------------------------")
print("BugHunt Pro V6 (Solara Ready)")
print("User: " .. user)
print("Status: Active")
print("--------------------------------------")

-- 5. تشغيل الواجهة (إذا قمت برفعها)
-- import("ui/main")
