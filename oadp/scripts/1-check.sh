echo "===== 1. DPA 상세 설정 ====="
oc get dpa dpa-sample -n oadp-operator -o yaml | \
egrep -A15 'resourceAllocations:|resourceTimeout:|timeout:|nodeAgent:|velero:'

echo
echo "===== 2. OADP Pod 메모리/CPU 설정 ====="
oc get pod -n oadp-operator \
  -o custom-columns='NAME:.metadata.name,CPU_REQ:.spec.containers[0].resources.requests.cpu,MEM_REQ:.spec.containers[0].resources.requests.memory,CPU_LIMIT:.spec.containers[0].resources.limits.cpu,MEM_LIMIT:.spec.containers[0].resources.limits.memory'

echo
echo "===== 3. OADP Pod restart / 종료이력 ====="
oc get pods -n oadp-operator -o json | jq -r '
.items[] |
[
 .metadata.name,
 (.status.containerStatuses[]?.restartCount // 0),
 (.status.containerStatuses[]?.lastState.terminated.reason // "-"),
 (.status.containerStatuses[]?.lastState.terminated.exitCode // "-")
] | @tsv
'

echo
echo "===== 4. BackupRepository ====="
oc get backuprepositories.velero.io -n oadp-operator 2>/dev/null || true

echo
echo "===== 5. 기존 Backup / Restore ====="
oc get backups.velero.io -n oadp-operator
oc get restores.velero.io -n oadp-operator

echo
echo "===== 6. 최근 OADP Warning ====="
oc get events -n oadp-operator \
  --field-selector type=Warning \
  --sort-by=.metadata.creationTimestamp | tail -30