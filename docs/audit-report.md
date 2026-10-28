# AWS Cloud Security & Governance — Rapport d'audit

## 1. Objectif

Évaluer plusieurs contrôles de sécurité d'un environnement AWS afin d'identifier les bonnes pratiques appliquées, les risques potentiels et les améliorations prioritaires.

L'audit porte notamment sur :
- la journalisation des événements avec AWS CloudTrail ;
- la protection des données stockées dans Amazon S3 ;
- le chiffrement et l'intégrité des journaux ;
- les permissions IAM et le principe du moindre privilège ;
- la protection des preuves d'audit.

## 2. Périmètre

- Région de vérification principale : `us-east-1`
- Trail CloudTrail : `CloudSecurityAuditTrail`
- Stockage des journaux : bucket S3 dédié
- Identité IAM examinée : utilisateur `Bamba`
- Politique personnalisée examinée : `BambaCustomAccess`
- Versions de la politique étudiées : v3, v4 et v5

Cet audit couvre uniquement les contrôles explicitement vérifiés. Il ne constitue pas un audit exhaustif du compte AWS.

## 3. Synthèse des résultats

| Contrôle | Résultat observé | Statut |
|---|---|---|
| Journalisation CloudTrail | Journalisation active lors de la vérification | PASS |
| Livraison des journaux | Livraison récente observée | PASS |
| Blocage public S3 au niveau du compte | Les quatre protections sont activées | PASS |
| Blocage public du bucket | Les quatre protections sont activées | PASS |
| Chiffrement du bucket | SSE-S3 avec AES-256 | PASS |
| Versionnement S3 | Désactivé | WARN |
| Permissions IAM étendues | Plusieurs politiques à privilèges élevés sont attachées à l'utilisateur | WARN |
| Suppression des objets d'audit | `s3:DeleteObject` est autorisé par la politique personnalisée | WARN |
| Gestion du cycle de vie CloudTrail | La politique personnalisée autorise notamment l'arrêt et la suppression du trail | WARN |
| Intégrité des journaux | Une validation partielle des fichiers digest a réussi | À SUIVRE |
| Protection contre une modification des preuves par un administrateur privilégié | Non vérifiée | À VÉRIFIER |

Les statuts reflètent les observations réalisées et non une certification globale de la sécurité du compte.

## 4. Analyse des risques

### 4.1 Protection et conservation des journaux S3

Le versionnement du bucket est désactivé. La suppression ou le remplacement d'un objet peut donc réduire les possibilités de récupération des données concernées.

La politique `BambaCustomAccess` autorise également `s3:DeleteObject` sur les objets du bucket. Cette permission augmente le risque de perte des preuves si les identifiants associés sont compromis ou si une suppression est effectuée par erreur.

**Recommandations :**
- évaluer les besoins de conservation et de récupération des journaux ;
- étudier une restriction du droit de suppression ;
- examiner les mécanismes de protection renforcée, notamment S3 Object Lock, en tenant compte de leurs contraintes et de leur coût ;
- ne modifier les permissions qu'après analyse des dépendances et validation de la procédure de retour arrière.

### 4.2 Permissions IAM et moindre privilège

L'utilisateur examiné possède notamment les politiques gérées `IAMFullAccess` et `AmazonEC2FullAccess`, qui accordent des permissions étendues.

La politique personnalisée `BambaCustomAccess` autorise également certaines opérations sensibles sur CloudTrail et S3.

**Recommandations :**
- déterminer quelles permissions sont réellement nécessaires aux tâches du projet ;
- séparer les opérations d'administration des accès de consultation ;
- limiter les actions et les ressources au strict nécessaire ;
- éviter de supprimer des permissions sans vérifier leur impact sur l'environnement de formation.

### 4.3 Évolution historique de la politique IAM

L'examen des versions de `BambaCustomAccess` montre les évolutions suivantes :

- **v3 :** permissions de lecture CloudTrail limitées et premières permissions S3 ;
- **v4 :** ajout de permissions S3 plus étendues, dont `s3:DeleteObject` ;
- **v5 :** ajout de permissions supplémentaires de gestion CloudTrail, dont `cloudtrail:StopLogging` et `cloudtrail:DeleteTrail`.

Ces permissions représentent des capacités sensibles. Leur présence ne prouve pas qu'elles ont été utilisées de manière abusive.

L'historique justifie une revue des besoins d'accès et des événements de modification de la politique. L'identité de l'auteur et la légitimité des modifications doivent être confirmées à partir des journaux et du contexte de l'environnement.

### 4.4 Intégrité et continuité de CloudTrail

CloudTrail permet de conserver une trace des événements AWS. La validation des fichiers digest peut contribuer à détecter des modifications de fichiers après leur livraison.

Une validation partielle a réussi lors des contrôles précédents. Cela ne permet pas de conclure que tous les journaux de toutes les périodes ont été validés.

**Recommandations :**
- poursuivre les validations sur des intervalles définis ;
- contrôler régulièrement l'état de journalisation et la livraison ;
- étudier des protections supplémentaires contre la suppression ou la modification des preuves ;
- examiner les autorisations permettant d'arrêter ou de supprimer le trail.

## 5. Automatisation de l'audit

Un script Bash de collecte en lecture seule a été créé dans `scripts/audit.sh`.

Il collecte notamment :
- l'identité AWS utilisée ;
- la configuration et l'état de CloudTrail ;
- les paramètres de blocage public et de chiffrement S3 ;
- l'état du versionnement ;
- les politiques attachées à l'utilisateur IAM et ses groupes ;
- les métadonnées des clés d'accès, sans enregistrer leur secret.

Les résultats sont enregistrés localement dans le dossier `evidence/`. Ces données peuvent contenir des informations sensibles et ne doivent pas être publiées sans examen et expurgation.

À ce stade, le script collecte des informations ; il ne réalise pas encore une évaluation automatique complète des contrôles PASS, WARN et FAIL.

## 6. Limites de l'audit

- Les résultats représentent un état observé à un instant donné.
- Les contrôles effectués ne couvrent pas toutes les ressources, politiques et régions du compte.
- La validation des digests n'a couvert qu'un intervalle partiel.
- Aucun test d'intrusion ni audit exhaustif n'a été réalisé.
- Les coûts et l'impact opérationnel des mesures correctives doivent être évalués avant leur déploiement.
- Les permissions identifiées comme risquées ne constituent pas, à elles seules, une preuve de compromission.

## 7. Plan d'amélioration

1. Finaliser la revue des permissions IAM et de leur historique.
2. Vérifier les événements associés aux modifications de la politique et au fonctionnement de CloudTrail.
3. Définir les exigences de conservation et de protection des journaux en fonction du budget.
4. Ajouter des contrôles automatiques PASS, WARN et FAIL au script d'audit.
5. Vérifier que les preuves brutes et les informations sensibles sont exclues du dépôt Git.
6. Publier une documentation expurgée avec les commandes utilisées, les résultats synthétiques et les recommandations.

## 8. Conclusion

Les contrôles réalisés montrent que plusieurs mesures de base sont en place : journalisation CloudTrail active, blocage public S3 au niveau du compte et du bucket, et chiffrement des données au repos avec SSE-S3.

Les principales pistes d'amélioration concernent le moindre privilège IAM, la suppression potentielle des journaux et la protection durable des preuves d'audit.

Ce projet constitue une démarche pratique d'apprentissage de la gouvernance et de la sécurité AWS. Les constats devront être actualisés après chaque nouvelle vérification ou correction.
