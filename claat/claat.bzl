load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_gazelle//:deps.bzl", "go_repository")

md_exts = [
    ".md",
]

def _impl(ctx):
    tmp = ctx.actions.declare_directory("TMP_" + ctx.label.name)

    src_paths = []
    for i in ctx.files.srcs:
        src_paths.append(i.path)

    cmd = "{claat} export -o {out} {srcs}".format(
        claat=ctx.executable._target.path,
        srcs=" ".join(src_paths),
        out=tmp.path,
    )

    ctx.actions.run_shell(
        inputs=ctx.files.srcs,
        outputs=[tmp],
        tools=[
            ctx.executable._target,
        ],
        command=cmd,
    )

    ctx.actions.run_shell(
        inputs=[tmp],
        outputs=[ctx.outputs.tar],
        command="tar -cf {output} -C {inn} .".format(
            inn=tmp.path,
            output=ctx.outputs.tar.path
        ),
    )

    return [DefaultInfo(runfiles=ctx.runfiles([ctx.outputs.tar]))]


claat = rule(
    implementation=_impl,
    attrs={
        # "src": attr.label(mandatory=True, allow_single_file=True),
        "srcs": attr.label_list(mandatory=True, allow_files=md_exts),
        "_target": attr.label(cfg="host",
                              allow_single_file=True, executable=True, default="@com_github_googlecodelabs_tools//claat")
    },
    outputs={
        "tar": "%{name}.tar",
    },
)

def claat_dependencies():
    """Installs all dependencies required by claat.
    """

    RULES_JVM_EXTERNAL_TAG = "3.0"

    RULES_JVM_EXTERNAL_SHA = "62133c125bf4109dfd9d2af64830208356ce4ef8b165a6ef15bbff7460b35c3a"

    http_archive(
        name="rules_jvm_external",
        sha256=RULES_JVM_EXTERNAL_SHA,
        strip_prefix="rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
        url="https://github.com/bazelbuild/rules_jvm_external/archive/%s.zip" % RULES_JVM_EXTERNAL_TAG,
    )

    http_archive(
        name="com_google_javascript_closure_compiler",
        build_file="@//third_party:BUILD.closure",
        url="https://repo1.maven.org/maven2/com/google/javascript/closure-compiler-unshaded/v20180805/closure-compiler-unshaded-v20180805.jar",
        sha256="facf537aad7f643c92771f71bd8d9c9b6830ec2aa56e458d2411678d8dc32368",
    )

    http_archive(
        name="bazel_skylib",
        urls=[
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        ],
        sha256="97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
    )

    http_archive(
        name="io_bazel_rules_closure",
        sha256="7d206c2383811f378a5ef03f4aacbcf5f47fd8650f6abbc3fa89f3a27dd8b176",
        strip_prefix="rules_closure-0.10.0",
        urls=[
            "https://mirror.bazel.build/github.com/bazelbuild/rules_closure/archive/0.10.0.tar.gz",
            "https://github.com/bazelbuild/rules_closure/archive/0.10.0.tar.gz",
        ],
    )

    http_archive(
        name="io_bazel_rules_webtesting",
        sha256="9bb461d5ef08e850025480bab185fd269242d4e533bca75bfb748001ceb343c3",
        urls=[
            "https://github.com/bazelbuild/rules_webtesting/releases/download/0.3.3/rules_webtesting.tar.gz",
        ],
    )

    prettify_ver = "2013-03-04"

    http_archive(
        name="prettify",
        build_file="@//third_party:BUILD.prettify",
        strip_prefix="code-prettify-{v}".format(v=prettify_ver),
        url="https://github.com/google/code-prettify/archive/{v}.zip".format(
            v=prettify_ver,
        ),
    )

    http_archive(
        name="polyfill",
        build_file="@//third_party:BUILD.polyfill",
        sha256="9606cdeacbb67f21fb495a4b0a0e5ea6a137fc453945907822e1b930e77124d4",
        strip_prefix="custom-elements-1.0.8",
        url="https://github.com/webcomponents/custom-elements/archive/v1.0.8.zip",
    )

    # Sass

    http_archive(
        name="io_bazel_rules_sass",
        # Make sure to check for the latest version when you install
        url="https://github.com/bazelbuild/rules_sass/archive/1.26.3.zip",
        strip_prefix="rules_sass-1.26.3",
        sha256="9dcfba04e4af896626f4760d866f895ea4291bc30bf7287887cefcf4707b6a62",
    )

    go_repository(
        name="com_github_bazelbuild_bazel_gazelle",
        importpath="github.com/bazelbuild/bazel-gazelle",
        sum="h1:buszGdD9d/Z691sxFDgOdcEUWli0ZT2tBXUxfbLMrb4=",
        version="v0.21.1",
    )

    go_repository(
        name="com_github_bazelbuild_buildtools",
        importpath="github.com/bazelbuild/buildtools",
        sum="h1:OfyUN/Msd8yqJww6deQ9vayJWw+Jrbe6Qp9giv51QQI=",
        version="v0.0.0-20190731111112-f720930ceb60",
    )

    go_repository(
        name="com_github_bazelbuild_rules_go",
        importpath="github.com/bazelbuild/rules_go",
        sum="h1:wzbawlkLtl2ze9w/312NHZ84c7kpUCtlkD8HgFY27sw=",
        version="v0.0.0-20190719190356-6dae44dc5cab",
    )

    go_repository(
        name="com_github_bmatcuk_doublestar",
        importpath="github.com/bmatcuk/doublestar",
        sum="h1:oC24CykoSAB8zd7XgruHo33E0cHJf/WhQA/7BeXj+x0=",
        version="v1.2.2",
    )

    go_repository(
        name="com_github_burntsushi_toml",
        importpath="github.com/BurntSushi/toml",
        sum="h1:WXkYYl6Yr3qBf1K79EBnL4mak0OimBfB0XUf9Vl28OQ=",
        version="v0.3.1",
    )

    go_repository(
        name="com_github_davecgh_go_spew",
        importpath="github.com/davecgh/go-spew",
        sum="h1:vj9j/u1bqnvCEfJOwUhtlOARqs3+rkHYY13jYWTU97c=",
        version="v1.1.1",
    )

    go_repository(
        name="com_github_fsnotify_fsnotify",
        importpath="github.com/fsnotify/fsnotify",
        sum="h1:IXs+QLmnXW2CcXuY+8Mzv/fWEsPGWxqefPtCP5CnV9I=",
        version="v1.4.7",
    )

    go_repository(
        name="com_github_golang_protobuf",
        importpath="github.com/golang/protobuf",
        sum="h1:P3YflyNX/ehuJFLhxviNdFxQPkGK5cDcApsge1SqnvM=",
        version="v1.2.0",
    )

    go_repository(
        name="com_github_google_go_cmp",
        importpath="github.com/google/go-cmp",
        sum="h1:/QaMHBdZ26BB3SSst0Iwl10Epc+xhTquomWX0oZEB6w=",
        version="v0.5.0",
    )

    go_repository(
        name="com_github_kr_pretty",
        importpath="github.com/kr/pretty",
        sum="h1:L/CwN0zerZDmRFUapSPitk6f+Q3+0za1rQkzVuMiMFI=",
        version="v0.1.0",
    )

    go_repository(
        name="com_github_kr_pty",
        importpath="github.com/kr/pty",
        sum="h1:VkoXIwSboBpnk99O/KFauAEILuNHv5DVFKZMBN/gUgw=",
        version="v1.1.1",
    )

    go_repository(
        name="com_github_kr_text",
        importpath="github.com/kr/text",
        sum="h1:45sCR5RtlFHMR4UwH9sdQ5TC8v0qDQCHnXt+kaKSTVE=",
        version="v0.1.0",
    )

    go_repository(
        name="com_github_pelletier_go_toml",
        importpath="github.com/pelletier/go-toml",
        sum="h1:T5zMGML61Wp+FlcbWjRDT7yAxhJNAiPPLOFECq181zc=",
        version="v1.2.0",
    )

    go_repository(
        name="com_github_pmezard_go_difflib",
        importpath="github.com/pmezard/go-difflib",
        sum="h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=",
        version="v1.0.0",
    )

    go_repository(
        name="com_github_russross_blackfriday_v2",
        importpath="github.com/russross/blackfriday/v2",
        sum="h1:lPqVAte+HuHNfhJ/0LC98ESWRz8afy9tM/0RK8m9o+Q=",
        version="v2.0.1",
    )

    go_repository(
        name="com_github_shurcool_sanitized_anchor_name",
        importpath="github.com/shurcooL/sanitized_anchor_name",
        sum="h1:PdmoCO6wvbs+7yrJyMORt4/BmY5IYyJwS/kOiWx8mHo=",
        version="v1.0.0",
    )

    go_repository(
        name="com_github_x1ddos_csslex",
        importpath="github.com/x1ddos/csslex",
        sum="h1:SX7lFdwn40ahL78CxofAh548P+dcWjdRNpirU7+sKiE=",
        version="v0.0.0-20160125172232-7894d8ab8bfe",
    )

    go_repository(
        name="com_google_cloud_go",
        importpath="cloud.google.com/go",
        sum="h1:eOI3/cP2VTU6uZLDYAoic+eyzzB9YyGmJ7eIjl8rOPg=",
        version="v0.34.0",
    )

    go_repository(
        name="in_gopkg_check_v1",
        importpath="gopkg.in/check.v1",
        sum="h1:qIbj1fsPNlZgppZ+VLlY7N33q108Sa+fhmuc+sWQYwY=",
        version="v1.0.0-20180628173108-788fd7840127",
    )

    go_repository(
        name="in_gopkg_yaml_v2",
        importpath="gopkg.in/yaml.v2",
        sum="h1:ZCJp+EgiOT7lHqUV2J862kp8Qj64Jo6az82+3Td9dZw=",
        version="v2.2.2",
    )

    go_repository(
        name="org_golang_google_appengine",
        importpath="google.golang.org/appengine",
        sum="h1:/wp5JvzpHIxhs/dumFmF7BXTf3Z+dd4uXta4kVyO508=",
        version="v1.4.0",
    )

    go_repository(
        name="org_golang_x_crypto",
        importpath="golang.org/x/crypto",
        sum="h1:psW17arqaxU48Z5kZ0CQnkZWQJsqcURM6tKiBApRjXI=",
        version="v0.0.0-20200622213623-75b288015ac9",
    )

    go_repository(
        name="org_golang_x_net",
        importpath="golang.org/x/net",
        sum="h1:VXak5I6aEWmAXeQjA+QSZzlgNrpq9mjcfDemuexIKsU=",
        version="v0.0.0-20200707034311-ab3426394381",
    )

    go_repository(
        name="org_golang_x_oauth2",
        importpath="golang.org/x/oauth2",
        sum="h1:TzXSXBo42m9gQenoE3b9BGiEpg5IG2JkU5FkPIawgtw=",
        version="v0.0.0-20200107190931-bf48bf16ab8d",
    )

    go_repository(
        name="org_golang_x_sync",
        importpath="golang.org/x/sync",
        sum="h1:vcxGaoTs7kV8m5Np9uUNQin4BrLOthgV7252N8V+FwY=",
        version="v0.0.0-20190911185100-cd5d95a43a6e",
    )

    go_repository(
        name="org_golang_x_sys",
        importpath="golang.org/x/sys",
        sum="h1:xhmwyvizuTgC2qz7ZlMluP20uW+C3Rm0FD/WLDX8884=",
        version="v0.0.0-20200323222414-85ca7c5b95cd",
    )

    go_repository(
        name="org_golang_x_text",
        importpath="golang.org/x/text",
        sum="h1:g61tztE5qeGQ89tm6NTjjM9VPIm088od1l6aSorWRWg=",
        version="v0.3.0",
    )

    go_repository(
        name="org_golang_x_tools",
        importpath="golang.org/x/tools",
        sum="h1:FkAkwuYWQw+IArrnmhGlisKHQF4MsZ2Nu/fX4ttW55o=",
        version="v0.0.0-20190122202912-9c309ee22fab",
    )

    go_repository(
        name="org_golang_x_xerrors",
        importpath="golang.org/x/xerrors",
        sum="h1:E7g+9GITq07hpfrRu66IVDexMakfv52eLZ2CXBWiKr4=",
        version="v0.0.0-20191204190536-9bdfabe68543",
    )
