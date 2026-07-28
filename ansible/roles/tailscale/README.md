# Rôle Ansible : tailscale

Installe Tailscale sur l'hôte (pas dans un conteneur) et active Tailscale SSH
pour un accès distant sécurisé sans exposer le port 22 publiquement.

## Structure à copier dans ton repo

```
roles/tailscale/
├── defaults/main.yml
├── handlers/main.yml
├── meta/main.yml
└── tasks/main.yml
playbook-tailscale.yml
```

## 1. Générer une auth key

Sur https://login.tailscale.com/admin/settings/keys :
- Génère une **auth key réutilisable** (pratique si tu réinstalles la machine),
  ou une clé à usage unique pour plus de sécurité.
- Recommandé : coche "Ephemeral: No" et fixe une expiration raisonnable
  (90 jours par exemple), tu la régénéreras au besoin.

## 2. Stocker la clé de façon sécurisée (ne JAMAIS la committer en clair)

Option recommandée avec ansible-vault :

```bash
ansible-vault encrypt_string 'tskey-auth-xxxxxxxxxxxx' --name 'tailscale_authkey' \
  >> group_vars/homelab/vault.yml
```

Puis dans `group_vars/homelab/vars.yml` (non chiffré), rien à faire de plus,
la variable sera résolue automatiquement au moment du run si vault.yml est
chargé dans ton inventaire.

Alternative rapide (test local) :

```bash
ansible-playbook playbook-tailscale.yml --extra-vars "tailscale_authkey=tskey-auth-xxxx"
```

## 3. Lancer le playbook

```bash
ansible-playbook -i inventory.ini playbook-tailscale.yml --ask-become-pass
```

## 4. Vérifier

Depuis n'importe quel appareil connecté au même tailnet :

```bash
tailscale ssh <utilisateur>@715q-homelab
```

## 5. Une fois que ça fonctionne bien

- Ferme le port 22 sur ton routeur/box (plus besoin de l'exposer publiquement).
- Repasse `tailscale_disable_password_auth: true` dans le playbook et relance
  pour forcer l'authentification par clé/Tailscale SSH uniquement.
- Ajoute des ACLs sur https://login.tailscale.com/admin/acls si tu veux
  restreindre qui peut SSH sur ce nœud (utile si tu ajoutes d'autres
  appareils/personnes au tailnet plus tard).

## Notes

- Le rôle s'installe sur l'**hôte du 715q**, indépendamment de K8s : tu gardes
  un accès de secours même si le cluster a un problème.
- `no_log: true` sur la tâche `tailscale up` évite que la auth key apparaisse
  dans les logs Ansible.
- Idempotent : si le nœud est déjà `Running`, le rôle ne relance pas `tailscale up`.
