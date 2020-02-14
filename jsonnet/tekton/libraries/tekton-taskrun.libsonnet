{

name:: error "name is required",
namespace:: error "namespace is required",
taskref:: error "taskref is required",
buildname:: error "buildname is required",

  "apiVersion": "tekton.dev/v1alpha1",
  "kind": "TaskRun",
  "metadata": {
    "name": $.name,
    "namespace": $.namespace,
  },
  "spec": {
    "taskRef": {
      "name": $.taskref,
    },
    "podTemplate": {
    "affinity": {
    "nodeAffinity": {
    "requiredDuringSchedulingIgnoredDuringExecution": {
    "nodeSelectorTerms": [{
      "matchExpressions": [
        {
          "key": "cloud.google.com/gke-nodepool",
          "operator": "In",
          "values": [
            "cicd"
          ]
        }
      ]
    }]
    }}}},
    "inputs": {
      "resources": [
        {
          "name": (std.join("-", ["git", $.buildname])),
          "resourceRef": {
            "name": (std.join("-", ["git", $.buildname])),
          }
        }
      ],
      "params": [
        {
          "name": "pathToContext",
          "value": "/workspace/git-hellok8s/",
          // "value": (std.join("/", ["/workspace", std.join("-", ["git", $.buildname])])),
        },
        {
          "name": "pathToDockerFile",
          "value": "Dockerfile",
          // "value": (std.join("/", ["/workspace", std.join("-", ["git", $.buildname]), "Dockerfile"])),
        }
      ]
    },
    "outputs": {
    "resources": [
      {
        "name": "builtImage",
        "resourceRef": {
          "name": (std.join("-", ["img", $.buildname]))
        }
      }
    ]
    }
  }
}