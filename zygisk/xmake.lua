set_languages("c++2b")
set_defaultarchs("arm64")

target("zygisk")
set_kind("shared")
set_filename("arm64-v8a.so")
set_targetdir("output")

on_clean(function(target)
    local output = path.join(target:scriptdir(), "output/*")
    local rust = path.join(target:scriptdir(), "rust")

    os.rmdir(output)
    os.cd(rust)
    os.exec("cargo clean")
end)

before_build(function(target)
    local output = path.join(target:scriptdir(), "output/*")
    local rust = path.join(target:scriptdir(), "rust")
    
    os.rm(output)
    os.cd(rust)

    if is_mode("debug") then
        os.exec("cargo build --target aarch64-linux-android")
        os.cp("target/aarch64-linux-android/debug/librust.a", "../output/librust.a")
    else
        os.exec("cargo build --release --target aarch64-linux-android")
        os.cp("target/aarch64-linux-android/release/librust.a", "../output/librust.a")
    end
end)

add_shflags("-nostdlib++")
add_links("rust", "binder_ndk", "log", "c++")
add_linkdirs("output", "../prebuilt")
add_files("src/*.cpp")
add_includedirs("rust/include")
