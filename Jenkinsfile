stage("Build") {
    parallel (
        "Windows" : {
            node('windows') {
                checkout poll: false, changelog: false, scm: scm
                bat 'git submodule update --init'
                bat 'powershell.exe .\\Build.ps1'
                stash includes: 'dist/**', name: 'windows'
                archiveArtifacts 'dist/**'
            }
        },
        "macOS" : {
            node('mac') {
                checkout poll: false, changelog: false, scm: scm
                sh 'git submodule update --init'
                sh './build.mac.sh'
                stash includes: 'dist/**', name: 'mac'
                archiveArtifacts 'dist/**'
            }
        },
        "Linux" : {
            node('linux') {
                checkout scm
                sh 'git submodule update --init'
                sh './build.linux.sh'
                stash includes: 'dist/**', name: 'linux'
                archiveArtifacts 'dist/**'
            }
        }
    )
}
if (env.BRANCH_NAME == 'master') {
  stage('Publish') {
    node('linux') {
      unstash 'windows'
      unstash 'mac'
      unstash 'linux'
      withCredentials([string(credentialsId: 'HiveMP-Deploy', variable: 'GITHUB_TOKEN')]) {
        sh("""
#!/bin/bash

set -e

echo "Creating SDK package..."
cd dist/
tar -czvf ../HiveMP.ClientConnect-SDK.tar.gz sdk
cd ..

echo "test" > test.txt
echo "Testing upload of new version works to ensure GitHub API is responding..."
\$GITHUB_RELEASE upload --user HiveMP --repo HiveMP.ClientConnect --tag latest --name TestUpload --file test.txt

echo "Deleting release from GitHub before creating a new one..."
\$GITHUB_RELEASE delete --user HiveMP --repo HiveMP.ClientConnect --tag latest || true

echo "Creating a new release on GitHub..."
\$GITHUB_RELEASE release --user HiveMP --repo HiveMP.ClientConnect --tag latest --name "Latest Release (Build \$BUILD_ID)" --description "This is an automatic release created by the build server.  The HiveMP.ClientConnect-SDK.tar.gz package contains pre-built binaries for all supported platforms."

echo "Uploading SDK to GitHub..."
\$GITHUB_RELEASE upload --user HiveMP --repo HiveMP.ClientConnect --tag latest --name HiveMP.ClientConnect-SDK.tar.gz --file HiveMP.ClientConnect-SDK.tar.gz

echo "Done!"
""")
      }
    }
  }
}