{

name:: error "name is required",
namespace:: error "namespace is required",
buildname:: error "buildname is required",

  "apiVersion": "tekton.dev/v1alpha1",
  "kind": "Task",
  "metadata": {
    "name": $.name,
    "namespace": $.namespace,
  },
  "spec": {
    "inputs": {
      "resources": [
        {
          "name": (std.join("-",["git", $.buildname])),
          "type": "git"
        }
      ],
      "params": [
        {
          "name": "pathToDockerFile",
          "description": "The path to the dockerfile to build",
          "default": "/workspace/workspace/Dockerfile"
        },
        {
          "name": "pathToContext",
          "description": "The build context used by Kaniko (https://github.com/GoogleContainerTools/kaniko#kaniko-build-contexts)",
          "default": "/workspace/workspace"
        }
      ]
    },
    "outputs": {
      "resources": [
        {
          "name": "builtImage",
          "type": "image"
        }
      ]
    },
    "steps": [
      {
        "name": "build-and-push",
        "image": "gcr.io/kaniko-project/executor:v0.15.0",
        "command": [
          "/kaniko/executor"
        ],
        "args": [
          "--dockerfile=${inputs.params.pathToDockerFile}",
          "--destination=${outputs.resources.builtImage.url}",
          "--context=${inputs.params.pathToContext}",
          "--cache=true",
          "--cache-ttl=6h",
          "--reproducible"
        ],
        "volumeMounts": [
          {
            "name": "kaniko-secret",
            "mountPath": "/secret"
          }
        ],
        "env": [
          {
            "name": "GOOGLE_APPLICATION_CREDENTIALS",
            "value": "/secret/kaniko-secret.json"
          },
          {
            "name": "DOCKER_CONFIG",
            "value": "/tekton/home/.docker/"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "kaniko-secret",
        "secret": {
          "secretName": "kaniko-secret"
        }
      }
    ]
  }
}
