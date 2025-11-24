{{/*
Expand the name of the chart.
*/}}
{{- define "application.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Priority: fullnameOverride > applicationName > Release.Name + chart name
*/}}
{{- define "application.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.applicationName }}
{{- .Values.applicationName | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "application.labels" -}}
helm.sh/chart: {{ include "application.chart" . }}
{{ include "application.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "application.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default .Release.Name .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the image repository for a resource
Priority: resource-specific > global default
*/}}
{{- define "application.imageRepository" -}}
{{- if .image.repository }}
{{- .image.repository }}
{{- else }}
{{- .global.repository }}
{{- end }}
{{- end }}

{{/*
Get the image tag for a resource
Priority: resource-specific > global default
*/}}
{{- define "application.imageTag" -}}
{{- if .image.tag }}
{{- .image.tag }}
{{- else }}
{{- .global.tag }}
{{- end }}
{{- end }}

{{/*
Get the image pull policy for a resource
Priority: resource-specific > global default
*/}}
{{- define "application.imagePullPolicy" -}}
{{- if .image.pullPolicy }}
{{- .image.pullPolicy }}
{{- else }}
{{- .global.pullPolicy }}
{{- end }}
{{- end }}

{{/*
Build the full image string
*/}}
{{- define "application.image" -}}
{{- $repository := include "application.imageRepository" . }}
{{- $tag := include "application.imageTag" . }}
{{- if and $repository $tag }}
{{- printf "%s:%s" $repository $tag }}
{{- else if $repository }}
{{- $repository }}
{{- else }}
{{- fail "Error: image repository must be specified either globally or per resource" }}
{{- end }}
{{- end }}
