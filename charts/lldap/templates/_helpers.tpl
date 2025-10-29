{{/*
================================================================================
IMAGE TAG HELPERS
================================================================================
*/}}

{{- define "lldap.image" -}}
{{ .Values.image.repository }}:{{ default .Chart.AppVersion .Values.image.tag }}
{{- end -}}

{{/*
================================================================================
BASE NAMING FUNCTIONS
================================================================================
*/}}
{{- define "lldap.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "lldap.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
================================================================================
COMPONENT NAMING FUNCTIONS
================================================================================
*/}}
{{- define "lldap.server.name" -}}
{{- printf "%s" (include "lldap.fullname" .) -}}
{{- end -}}

{{- define "lldap.server.serviceName" -}}
{{- $default := include "lldap.server.name" . -}}
{{- default $default .Values.service.name -}}
{{- end -}}

{{/*
================================================================================
SERVICE ACCOUNT FUNCTIONS
================================================================================
*/}}
{{- define "lldap.server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "lldap.server.name" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
================================================================================
STANDARD KUBERNETES LABELS (Applied to ALL resources)
================================================================================
*/}}
{{- define "lldap.standardLabels" -}}
app.kubernetes.io/name: {{ include "lldap.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{/*
================================================================================
HELM METADATA LABELS (Applied to ALL resources)
================================================================================
*/}}
{{- define "lldap.helmLabels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
helm.sh/release: {{ .Release.Name }}
helm.sh/revision: {{ .Release.Revision | quote }}
{{- end -}}

{{/*
================================================================================
COMPLETE RESOURCE LABELS (Standard + Helm + Custom)
================================================================================
*/}}
{{- define "lldap.labels" -}}
{{- $standard := include "lldap.standardLabels" . | fromYaml -}}
{{- $helm := include "lldap.helmLabels" . | fromYaml -}}
{{- $result := merge (dict) $standard $helm -}}
{{- with .Values.commonLabels }}{{- $result = merge $result . -}}{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{/*
================================================================================
SELECTOR LABELS (Minimal set for matching pods)
================================================================================
*/}}
{{- define "lldap.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end -}}

{{/*
================================================================================
COMPONENT-SPECIFIC LABELS
================================================================================
*/}}
{{- define "lldap.server.labels" -}}
{{- $base := include "lldap.labels" . | fromYaml -}}
{{- $component := dict "app.kubernetes.io/component" "server" -}}
{{- $result := merge (dict) $base $component -}}
{{- with .Values.server.labels }}{{- $result = merge $result . -}}{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{/*
================================================================================
POD LABELS (selector + component + optional pod-specific)
================================================================================
*/}}
{{- define "lldap.server.podLabels" -}}
{{- $selector := include "lldap.selectorLabels" (dict "name" (include "lldap.name" .) "root" .) | fromYaml -}}
{{- $component := include "lldap.server.labels" . | fromYaml -}}
{{- $result := merge (dict) $selector $component -}}
{{- with .Values.podLabels }}{{- $result = merge $result . -}}{{- end }}
{{- with .Values.server.podLabels }}{{- $result = merge $result . -}}{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{/*
================================================================================
STANDARD ANNOTATIONS (Applied to ALL resources)
================================================================================
*/}}
{{- define "lldap.standardAnnotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end -}}

{{/*
================================================================================
COMPLETE RESOURCE ANNOTATIONS
================================================================================
*/}}
{{- define "lldap.annotations" -}}
{{- $std := include "lldap.standardAnnotations" . | fromYaml -}}
{{- $result := merge (dict) $std -}}
{{- with .Values.commonAnnotations }}{{- $result = merge $result . -}}{{- end }}
{{- if $result }}{{- toYaml $result -}}{{- end }}
{{- end -}}

{{/*
================================================================================
POD ANNOTATIONS
================================================================================
*/}}
{{- define "lldap.server.podAnnotations" -}}
{{- $base := include "lldap.annotations" . | fromYaml -}}
{{- $result := merge (dict) $base -}}
{{- with .Values.podAnnotations }}{{- $result = merge $result . -}}{{- end }}
{{- with .Values.server.podAnnotations }}{{- $result = merge $result . -}}{{- end }}
{{- if $result }}{{- toYaml $result -}}{{- end }}
{{- end -}}

{{/*
================================================================================
SERVICE ANNOTATIONS
================================================================================
*/}}
{{- define "lldap.server.serviceAnnotations" -}}
{{- $base := include "lldap.annotations" . | fromYaml -}}
{{- $result := merge (dict) $base -}}
{{- with .Values.service.annotations }}{{- $result = merge $result . -}}{{- end }}
{{- if $result }}{{- toYaml $result -}}{{- end }}
{{- end -}}

{{/*
================================================================================
NETWORK HELPERS
================================================================================
*/}}
{{- define "lldap.server.internalURL" -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" (include "lldap.server.serviceName" .) .Release.Namespace .Values.service.httpPort -}}
{{- end -}}
