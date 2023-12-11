#!/bin/bash

# Verificar que se haya proporcionado un argumento
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 [ruta del archivo de respaldo]"
    exit 1
fi

# Configuración interna
DB_NAME="northwind"
DB_USER="north"
DB_PASS="secret"
LOG_FILE="/home/vagrant/backups/restore_log.txt" # Archivo de log
BACKUP_FILE="$1" # Usar el argumento proporcionado

# Función para crear un respaldo antes de la restauración
backup_before_restore() {
    local backup_file="/home/vagrant/backups/before_restore_from_$(basename $BACKUP_FILE)_$(date +%Y%m%d%H%M%S).sql"
    mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > "$backup_file"
    echo "Backup previo creado: $backup_file"
}

# Comprobar si el archivo de respaldo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "El archivo de respaldo $BACKUP_FILE no existe."
    exit 1
fi

# Opción para realizar un respaldo previo
read -p "¿Desea crear un respaldo previo? (s/n): " answer
if [ "$answer" = "s" ]; then
    backup_before_restore
fi

# Restaurar la base de datos
mysql -u $DB_USER -p$DB_PASS $DB_NAME < "$BACKUP_FILE"

# Registrar en el log
echo "$(date +%Y-%m-%d %H:%M:%S) - Restauración realizada con el archivo $BACKUP_FILE" >> $LOG_FILE
echo "Restauración completada y registrada en el log."
