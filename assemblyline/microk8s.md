## resources

- https://github.com/CybercentreCanada/assemblyline-helm-chart/tree/master/assemblyline
- https://microk8s.io/

## tasks

```bash
# install microk8s [ubuntu / xubuntu]

sudo snap install microk8s --classic

# add current user to microk8s group

sudo usermod -a -G microk8s $USER

# activer les services nécessaires

microk8s enable ingress storage helm3 dashboard dns registry istio

# se rendre dans le dossier du Chart helm

cd assemblyline-helm-chart/assemblyline

# télécharger les dépendances manquantes

microk8s helm3 dependency update

# cf. https://github.com/helm/helm/issues/8137 > la fonction lookup semble être désactivée maintenant...

# dans templates/secrets.yaml supprimer la ligne 2 et la derniere ligne

# configurer les storage class

# dans le fichier values.yaml

# changer ligne 23 internalLogging > true

# changer les lignes suivantes :

redisStorageClass: redis-storage
updateStorageClass: update-storage

# lancer le dashboard

microk8s dashboard-proxy

# se rendre sur le dashboard https://127.0.0.1:10443

# creer les secrets (bouton "+" dans le dashboard) avec le yaml suivant :

apiVersion: v1
kind: Secret
metadata:
  name: assemblyline-system-passwords
type: Opaque
stringData:
  datastore-password: "assemblyline-password"
  logging-password: "assemblyline-password"
  filestore-password: "assemblyline-password"
  initial-admin-password: "assemblyline-password"

# tenter de déployer le chart
# cf. https://github.com/helm/helm/issues/8137 > la fonction lookup semble être désactivée maintenant...

microk8s helm3 install assemblyline ./ --dry-run

# si tout semble OK, appliquer

microk8s helm3 install assemblyline ./

```
