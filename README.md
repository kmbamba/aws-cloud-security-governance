# AWS Cloud Security & Governance

## Présentation

Ce projet met en œuvre une démarche pratique d’audit de sécurité et de gouvernance sur AWS. Il vise à vérifier la configuration de contrôles essentiels, à examiner les permissions IAM et à collecter des preuves techniques permettant de documenter les risques et les pistes d’amélioration.

Le projet privilégie une approche **read-only pour l’audit automatisé**, la traçabilité des opérations et la maîtrise des coûts.

## Objectifs

- Vérifier la configuration et l’activité d’AWS CloudTrail.
- Contrôler les paramètres de blocage des accès publics Amazon S3.
- Vérifier le chiffrement du bucket d’audit.
- Examiner les permissions IAM et identifier les privilèges excessifs.
- Documenter les risques liés à la suppression des journaux et à la gestion des politiques.
- Automatiser la collecte locale des éléments nécessaires à l’audit.

## Architecture et services AWS

- **AWS CloudTrail** : journalisation des événements d’activité du compte.
- **Amazon S3** : stockage des journaux CloudTrail.
- **AWS IAM** : examen des politiques et des permissions.
- **AWS CLI** : interrogation des configurations et collecte des informations.
- **Bash** : automatisation des contrôles.
- **Git et GitHub** : gestion de versions du code et documentation du projet.

## Contrôles réalisés

| Contrôle | Résultat observé |
|---|---|
| Journalisation CloudTrail | Active |
| Livraison récente des journaux | Confirmée lors de l’audit |
| Blocage des accès publics S3 | Activé au niveau du compte et du bucket |
| Chiffrement du bucket | SSE-S3 (AES-256) |
| Versioning du bucket | Désactivé ; amélioration à évaluer |
| Permissions IAM | Présence de politiques à privilèges étendus |
| Suppression d’objets S3 | Permission identifiée dans la politique personnalisée |
| Gestion de CloudTrail | Permissions sensibles de modification et de suppression identifiées |
| Validation des fichiers digest CloudTrail | Vérification partielle effectuée |

Ces constats décrivent la configuration observée au moment de l’audit. Ils ne constituent pas une certification de conformité ni une preuve de compromission.

## Risques et axes d’amélioration

1. **Principe du moindre privilège** : examiner les politiques IAM trop permissives et réduire les permissions au strict nécessaire après validation des dépendances.
2. **Protection des journaux** : évaluer les moyens de limiter la suppression ou la modification des preuves d’audit.
3. **Intégrité des journaux** : poursuivre la validation des fichiers digest CloudTrail.
4. **Gestion des politiques** : suivre les évolutions des permissions et limiter les capacités d’arrêt ou de suppression de la journalisation.
5. **Résilience** : évaluer le versioning S3 et les mécanismes de rétention selon les besoins, les risques et le budget.

Aucune politique IAM n’est modifiée automatiquement par le script d’audit.

## Automatisation

Le script `scripts/audit.sh` collecte localement des informations sur :

- l’identité AWS utilisée ;
- la configuration et l’état de CloudTrail ;
- les paramètres de blocage des accès publics S3 ;
- le chiffrement et le versioning du bucket ;
- les politiques IAM attachées à l’utilisateur, ses groupes et les métadonnées de ses clés d’accès.

Les résultats sont enregistrés dans le dossier `evidence/`, exclu du dépôt Git afin d’éviter la publication de données propres au compte.

## Exécution

### Prérequis

- AWS CLI installé et configuré.
- Des permissions AWS suffisantes pour les opérations de lecture demandées.
- Bash sur Linux, WSL Ubuntu ou un environnement compatible.
- Accès au compte AWS dans lequel les contrôles doivent être réalisés.

### Lancer l’audit

Depuis la racine du projet :

```bash
chmod +x scripts/audit.sh

export AUDIT_BUCKET_NAME="your-audit-bucket-name"

./scripts/audit.sh
```

La région utilisée par défaut est `us-east-1`. Elle peut être remplacée avec la variable d’environnement `AWS_REGION` si nécessaire.

Le script ne déploie pas de nouveaux services AWS et ne modifie pas intentionnellement les ressources auditées. Il effectue des appels de lecture et écrit les résultats localement.

## Structure du projet

```text
aws-cloud-security-governance/
├── README.md
├── .gitignore
├── docs/
│   └── audit-report.md
├── scripts/
│   └── audit.sh
└── evidence/                 # Exclu de Git
    ├── cloudtrail/
    ├── iam/
    └── s3/
```

## Rapport d’audit

Le document `docs/audit-report.md` présente le périmètre, les résultats, les risques identifiés, les limites de l’audit et les améliorations envisagées.

## Sécurité et coûts

- Les preuves brutes restent locales et ne doivent pas être publiées sans vérification et expurgation.
- Aucun secret, identifiant de clé d’accès ou fichier de configuration local ne doit être ajouté au dépôt.
- Les modifications de politiques IAM doivent être planifiées et validées avant toute application.
- Les services AWS susceptibles d’entraîner des coûts supplémentaires doivent être évalués avant activation.
- Le projet ne prétend pas démontrer une conformité réglementaire complète.

## Limites actuelles

La collecte automatisée ne produit pas encore une évaluation complète et automatique de type PASS/WARN/FAIL. La validation des digest CloudTrail reste à compléter, et les mécanismes de protection renforcée contre la suppression des journaux doivent encore être évalués.

## Compétences mises en pratique

AWS IAM, AWS CloudTrail, Amazon S3, AWS CLI, Bash, audit de configuration, analyse de permissions, principe du moindre privilège, journalisation, intégrité des preuves, documentation technique et gestion de versions avec Git.

---

*Projet personnel de mise en pratique de la sécurité et de la gouvernance AWS.*
