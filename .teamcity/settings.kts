import jetbrains.buildServer.configs.kotlin.BuildFeatures
import jetbrains.buildServer.configs.kotlin.BuildType
import jetbrains.buildServer.configs.kotlin.DslContext
import jetbrains.buildServer.configs.kotlin.buildFeatures.commitStatusPublisher
import jetbrains.buildServer.configs.kotlin.buildFeatures.perfmon
import jetbrains.buildServer.configs.kotlin.buildSteps.exec
import jetbrains.buildServer.configs.kotlin.project
import jetbrains.buildServer.configs.kotlin.projectFeatures.githubIssues
import jetbrains.buildServer.configs.kotlin.triggers.vcs
import jetbrains.buildServer.configs.kotlin.version

/*
The settings script is an entry point for defining a TeamCity
project hierarchy. The script should contain a single call to the
project() function with a Project instance or an init function as
an argument.

VcsRoots, BuildTypes, Templates, and subprojects can be
registered inside the project using the vcsRoot(), buildType(),
template(), and subProject() methods respectively.

To debug settings scripts in command-line, run the

    mvnDebug org.jetbrains.teamcity:teamcity-configs-maven-plugin:generate

command and attach your debugger to the port 8000.

To debug in IntelliJ Idea, open the 'Maven Projects' tool window (View
-> Tool Windows -> Maven Projects), find the generate task node
(Plugins -> teamcity-configs -> teamcity-configs:generate), the
'Debug' option is available in the context menu for the task.
*/

version = "2023.11"

project {

    buildType(createBuild("workshops", "workflows"))
    buildType(createBuild("git-days", "day-1"))
    buildType(createBuild("git-days", "day-2"))
    buildType(createBuild("git-days", "exercise-1"))
    buildType(createBuild("git-days", "exercise-2"))

    features {
        githubIssues {
            id = "PROJECT_EXT_3"
            displayName = "sourcegrade/git-workshop"
            repositoryURL = "https://github.com/sourcegrade/git-workshop"
            authType = accessToken {
                accessToken = "credentialsJSON:7828090f-5bd5-448c-99df-b7fae9540192"
            }
            param("tokenId", "")
        }
    }
}

fun createBuild(buildGroup: String, buildName: String): BuildType {
    return object : BuildType() {
        init {
            id("${buildGroup}_$buildName".replace('-', '_'))
            name = "$buildGroup/$buildName"

            configureVcs()
            configureTriggers()
            features {
                configureBaseFeatures()
            }

            requirements {
                contains("env.AGENT_NAME", "tex")
            }

            steps {
                exec {
                    name = "Clean up old pdf"
                    path = "make"
                    arguments = "cleanBuild"
                }
                exec {
                    name = "Build $buildGroup/$buildName with AlgoTeX"
                    path = "make"
                    arguments = "-j FILES=$buildGroup/$buildName.tex"
                }
                exec {
                    name = "Create final pdf"
                    workingDir = "build"
                    path = "cp"
                    arguments = "$buildName.pdf $buildGroup-$buildName-RC%env.BUILD_NUMBER%.pdf"
                }
                exec {
                    name = "Create final pdf (darkmode)"
                    workingDir = "build"
                    path = "cp"
                    arguments = "$buildName-darkmode.pdf $buildGroup-$buildName-RC%env.BUILD_NUMBER%-darkmode.pdf"
                }
            }

            artifactRules = "+:./build/$buildGroup-$buildName-RC%env.BUILD_NUMBER%*.pdf"
        }
    }
}

fun BuildType.configureVcs() {
    vcs {
        root(DslContext.settingsRoot)
    }
}

fun BuildType.configureTriggers() {
    triggers {
        vcs {
            branchFilter = "+:*"
        }
    }
}

fun BuildFeatures.configureBaseFeatures() {
    perfmon {}
    commitStatusPublisher {
        vcsRootExtId = "${DslContext.settingsRoot.id}"
        publisher = github {
            githubUrl = "https://api.github.com"
            authType = personalToken {
                token = "credentialsJSON:7828090f-5bd5-448c-99df-b7fae9540192"
            }
        }
    }
}
