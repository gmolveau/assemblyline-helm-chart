{{ define "assemblyline.coreEnv" }}
- name: LOGGING_PASSWORD
  valueFrom:
    secretKeyRef:
      name: assemblyline-system-passwords
      key: logging-password
- name: LOGGING_HOST
  valueFrom:
    configMapKeyRef:
      name: system-settings
      key: logging-host
- name: LOGGING_USERNAME
  valueFrom:
    configMapKeyRef:
      name: system-settings
      key: logging-username
- name: ELASTIC_PASSWORD
  valueFrom:
    secretKeyRef:
      name: assemblyline-system-passwords
      key: datastore-password
{{ if .Values.internalFilestore }}
- name: INTERNAL_FILESTORE_ACCESS
  valueFrom:
    secretKeyRef:
      name: internal-filestore-keys
      key: accesskey
- name: INTERNAL_FILESTORE_KEY
  valueFrom:
    secretKeyRef:
      name: internal-filestore-keys
      key: secretkey
{{ else }}
- name: FILESTORE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: assemblyline-system-passwords
      key: filestore-password
{{ end }}
{{ if .Values.coreEnv }}
{{- .Values.coreEnv | toYaml -}}
{{ end }}
{{ end }}
---
{{ define "assemblyline.coreMounts" }}
- name: al-config
  mountPath: /etc/assemblyline/config.yml
  subPath: config
{{ if .Values.coreMounts }}
{{- .Values.coreMounts | toYaml -}}
{{ end }}
{{ end }}
---
{{ define "assemblyline.coreVolumes" }}
- name: al-config
  configMap:
    name: {{ .Release.Name }}-global-config
{{ if .Values.coreVolumes }}
{{- .Values.coreVolumes | toYaml -}}
{{ end }}
{{ end }}
---
{{ define "assemblyline.coreService" }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .component }}
  labels:
    app: assemblyline
    section: core
    component: {{ .component }}
spec:
  replicas: {{ .replicas | default 1 }}
  selector:
    matchLabels:
      app: assemblyline
      section: core
      component: {{ .component }}
  template:
    metadata:
      labels:
        app: assemblyline
        section: core
        component: {{ .component }}
    spec:
      priorityClassName: al-core-priority
      containers:
        - name: {{ .component }}
          image: {{ .Values.assemblylineCoreImage }}:{{ .Values.coreVersion }}
          imagePullPolicy: Always
          command: ['python', '-m', '{{ .command }}']
          volumeMounts:
          {{ include "assemblyline.coreMounts" . | indent 12 }}
          resources:
            requests:
              memory: 128Mi
              cpu: 0.05
            limits:
              memory: 1Gi
              cpu: 1
          env:
          {{ include "assemblyline.coreEnv" . | indent 12 }}
      volumes:
      {{ include "assemblyline.coreVolumes" . | indent 8 }}
{{ end }}

