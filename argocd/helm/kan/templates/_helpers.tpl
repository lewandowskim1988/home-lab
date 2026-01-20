{{- define "kan.labels" -}}
helm.sh/chart: {{ include "kan.chart" . }}
{{ include "kan.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "kan.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "kan.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "kan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "kan.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "kan.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kan.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
betterAuthSecret value
*/}}
{{- define "kan.betterAuthSecret" -}}
{{- if not .Values.betterAuthSecret -}}
{{- $rand := randAlphaNum 32 | b64enc -}}
{{- $_ := set .Values "betterAuthSecret" $rand -}}
{{- end -}}
{{- .Values.betterAuthSecret -}}
{{- end -}}
