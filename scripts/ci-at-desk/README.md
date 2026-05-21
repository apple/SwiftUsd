# ci-at-desk

A script for running SwiftUsd CI workflows locally



## Using ci-at-desk

ci-at-desk requires a YAML configuration file. Here is a sample YAML config file.
```
 workflow: Run-Tests
 
 precheckouts:
 - remote: git@github.com:apple/SwiftUsd
   ref: 7.0.0
   path: precheckouts/SwiftUsd
 - remote: git@github.com:apple/SwiftUsd-Tests
   ref: 7.0.0
   path: precheckouts/SwiftUsd-Tests
 
 requiredPaths:
   cache: cache
   artifacts: artifacts
   runnerRoot: runnerRoot
   logging: logging
   SwiftUsd: precheckouts/SwiftUsd
   SwiftUsd-Tests: precheckouts/SwiftUsd-Tests

 ci-inputs:
   build-targets: ALL
   openusd-ref: v26.03
   swiftusd-ref: local
   swiftusd-tests-ref: local
```

To use it:
1. Create an empty directory at `~/Desktop/ci-at-desk-runs`
2. Paste the contents of the YAML config file into `~/Desktop/ci-at-desk-runs/config.yaml`
3. Run `cd ~/SwiftUsd/scripts/ci-at-desk; swift run --configuration release ci-at-desk ~/Desktop/ci-at-desk-runs/config.yaml`
 
Given this config file, ci-at-desk will:
1. Create these directories:
    - `~/Desktop/ci-at-desk-runs/precheckouts`
    - `~/Desktop/ci-at-desk-runs/cache`
    - `~/Desktop/ci-at-desk-runs/artifacts`
    - `~/Desktop/ci-at-desk-runs/runnerRoot`
    - `~/Desktop/ci-at-desk-runs/logging`
2. Clone SwiftUsd and SwiftUsd-Tests into `~/Desktop/ci-at-desk-runs/precheckouts`
3. Run the CI test suite in parallel using `~/Desktop/ci-at-desk-runs/precheckouts/SwiftUsd` and `~/Desktop/ci-at-desk-runs/precheckouts/SwiftUsd-Tests`



## YAML config file syntax

### Paths

Paths in the YAML config are interpreted differently based on their starting characters:
- Paths beginning with `/` are treated as absolute paths
- Paths beginning with `~/` have tilde expansion performed (i.e. `~/foo` becomes `/Users/<username>/foo`)
- All other paths are treated as paths relative to the directory containing the config file (i.e. `foo` in a config file at `/fizz/buzz` becomes `/fizz/foo`)

### YAML fields
 
`workflow`: string, the id of the workflow to run. Required.
 
`precheckouts`: array of precheckout objects. Optional, defaults to empty array.
- `precheckouts[*].remote`: string of github remote to clone from, e.g. `git@github.com:apple/SwiftUsd`. Required.
- `precheckouts[*].ref`: string of ref to checkout after cloning, e.g. `6.1.0`. Required.
- `precheckouts[*].path`: string path to clone to, e.g. `precheckouts/SwiftUsd`. Required.

`requiredPaths`:
- `requiredPaths.runnerRoot`: string path under which to create the directories for individual matrix instance runs. **If the directory already exists, it will be removed.** Required.
- `requiredPaths.cache`: string path under which to store cache objects between different CI runs. If the directory doesn't exist, it will be created. Required.
- `requiredPaths.artifacts`: string path under which to store artifacts created during a CI run. **If the directory already exists, it will be removed.** Required.
- `requiredPaths.logging`: string path under which to write log files during CI runs. **If the directory already exists, it will be removed.** Required.
- `requiredPaths.SwiftUsd`: string path containing a local SwiftUsd repo to use for CI runs. Required.
- `requiredPaths.SwiftUsd-Tests`: string path containing a local SwiftUsd-Tests repo to use for CI runs. Required.
 
`ci-inputs[*]`: a map of variables that will get inserted into orchestrator/runner contexts under `inputs`. Optional, defaults to empty map.

`max-parallelism`:
- `max-parallelism.jobs`: int limiting the maximum number of jobs that may run in parallel under an individual workflow, with <=0 meaning no limit. Optional, defaults to 0.
- `max-parallelism.matrices`: int limiting the maximum number of matrix instances that may run in parallel under an individual job, with <=0 meaning no limit. Optional, defaults to 0.
- `max-parallelism.ATDESK_SWIFTBUILD_JOBS`: int limiting the maximum number of jobs swift-build can spawn (passed as `--jobs N`), with <= 0 meaning no limit. Optional, defaults to 0.
- `max-parallelism.ATDESK_XCODEBUILD_JOBS`: int limiting the maximum number of jobs xcodebuild can spawn (passed as `-jobs N`), with <= 0 meaning no limit. Optional, defaults to 0.
- `max-parallelism.timeoutScaleFactor`: float scaling the maximum timeout for steps/jobs, with <= 0 meaning 1. Useful for systems with high load or when ci-at-desk has low scheduling priority. Optional, defaults to 1. 

`skips[*]`: a map of strings to ints that will get inserted into orchestrator/runner contexts under `skips`. Optional, defaults to empty map.

`env[*]:` a map of strings to strings that will get inserted into the environment before running shell commands during step execution. Optional, defaults to empty map. Here are some common keys:
- `env.ATDESK_IOS_XCODEBUILD_DESTINATION`: string for a `-destination` xcodebuild argument for a physical iOS device to use for CI test suite runs. Optional, defaults to empty string. e.g. "platform=iOS,name=My iPad Pro".
- `env.ATDESK_VISIONOS_XCODEBUILD_DESTINATION`: string for a `-destination` xcodebuild argument for a physical visionOS device to use for CI test suite runs. Optional, defaults to empty string. e.g. "platform=visionOS,name=My Apple Vision Pro".
- `env.ATDESK_DEVELOPMENT_TEAM`: string for a `DEVELOPMENT_TEAM=` xcodebuild build setting override to use for CI test suite runs on a physical iOS or visionOS device. Optional, defaults to empty string.
- `env.SWIFTLY_ASSUME_INSTALLED`: Comma-separated string of toolchains to assume are installed when determining test combinations. Optional, defaults to empty string.
- `env.SWIFTLY_DENYLIST`: Denylist string for Swiftly toolchains to use when determining test combinations. Optional, defaults to `-`.
- `env.XCODE_DENYLIST`: Denylist string for Xcodes to use when determining test combinations. Optional, defaults to `-`.

### Development Team:

You can find a valid development team argument by running `security find-certificate -c $(security find-identity -vp codesigning | grep ')' | head -n 1 | sed -E 's/.*\((.*)\).*/\1/') -p | openssl x509 -subject | grep 'OU=' | sed -E 's/.*\/OU=([A-Za-z0-9_]+)\/.*/\1/'`
Or as a step by step process:
1. `security find-identity -vp codesigning` will print out 0 or more valid code signing identities in your keychain.
2. `<step-1> | grep ')' | head -n 1 |` will choose the first line that contains `)`
3. `<step-2> | sed -E 's/.*\((.*)\).*/\1/'` will extract the parenthesized section at the end of a line from the output in step 1.
4. `security find-certificate -c <step-3> -p` will print out the certificate for the code sign identity from step 3.
5. `<step-4> | openssl x509 -subject` will print out the certificate as well fields like the User ID (UID), Common Name (CN), Organizational Unit (OU), Organization (O), and Country (C).
6. `<step-5> | sed -E 's/.*\/OU=([A-Za-z0-9_]+)\/.*/\1/` will extract the value of the OU field, i.e. the `DEVELOPMENT_TEAM` argument

### Denylist String:

A denylist string is a comma-separated string of rules to apply to a Swiftly toolchain or Xcode installation to control how the CI system determines test combinations. Each rule begins with either `-` to exclude or `+` to include, followed by a regex. If the regex matches somewhere in a potential toolchain/installation, the rule is applied:
```
env.SWIFTLY_DENYLIST: "-snapshot" # Exclude all snapshots
env.SWIFTLY_DENYLIST: "-,+^6.2,+xcode" # Exclude all toolchains, then add in 6.2.x and the Xcode system toolchain
env.XCODE_DENYLIST: "-" # Exclude all Xcodes. (Only the currently active Xcode will be used)
env.XCODE_DENYLIST: "-,+26" # Exclude all Xcodes, then include any containing `26` in their name
```


## Architecture

ci-at-desk is structured into three targets:
- WorkflowDescription contains the types used for defining a workflow consisting of jobs and steps.
- WorkflowRunning contains the logic for orchestrating and running a workflow invocation.  
  "Orchestrating" refers to scheduling parallel subtasks (WorkflowOrchestrator kicks off JobOrchestrator instances, JobOrchestrator kicks off MatrixInstanceRunner instances), while "Running" refers to serially executing subtasks (MatrixInstanceRunner runs StepRunner instances in order, StepRunner performs the underlying work of an individual step, including dealing with caching).  
  `YamlConfig.swift` also lives here.  
- ci-at-desk is the executable entry point. It can be used as a command line program, and on macOS it can also be used with the --ui flag to see a SwiftUI GUI version that automatically monitors the logs of the running workflow. The actual workflow definitions live in `ci_at_desk.swift`. 
