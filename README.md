# KipuBank 🏦

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.0-363636)](https://docs.soliditylang.org/)

> ⚠️ **ADVERTENCIA**: Este contrato es únicamente para fines educativos y de prueba. NO utilizar en producción con fondos reales.

## Descripción

KipuBank es un contrato inteligente de bóveda (vault) simple que permite a los usuarios depositar y retirar ETH de manera segura. Implementa límites operacionales fijos, protección contra reentrancia y un sistema de eventos para rastrear todas las transacciones.

### Características principales

- 💰 **Depósitos de ETH**: Los usuarios pueden depositar tokens nativos en su bóveda personal
- 💸 **Retiros limitados**: Sistema de retiro con límite máximo por transacción
- 🔒 **Límite global**: Cap total de depósitos definido al momento del despliegue
- 🛡️ **Seguridad**: Protección contra reentrancia y validaciones exhaustivas
- 📊 **Trazabilidad**: Eventos emitidos en cada operación
- 📈 **Estadísticas**: Contador de depósitos y retiros realizados

## Arquitectura del Contrato

### Variables de Estado

- `WITHDRAWAL_LIMIT` (immutable): Límite máximo de retiro por transacción
- `BANK_CAP` (immutable): Cap global de depósitos permitidos
- `withdrawalCount`: Contador total de retiros ejecutados
- `depositCount`: Contador total de depósitos ejecutados
- `totalBalance`: Balance acumulado total en el contrato
- `vault`: Mapping que almacena el balance de cada usuario

### Eventos

```solidity
event DepositReceived(address sender, uint256 amount);
event WithdrawalPerformed(address owner, uint256 amount);
```

### Errores Personalizados

```solidity
error TransactionFailed(bytes reason);
error BankCapReached(uint256 totalBalance);
error InvalidAmount(uint amount);
```

## Cómo Interactuar con el Contrato

### 1. Depositar ETH

Para depositar ETH en tu bóveda personal:

**Desde Sepolia Testnet Explorer:**
1. Ve a la pestaña "Write Contract"
2. Conecta tu wallet
3. Busca la función `deposit`
4. Ingresa la cantidad de ETH a depositar en el campo "payableAmount"
5. Click en "Write"


### 2. Retirar ETH

Para retirar ETH de tu bóveda:

**Desde Sepolia Testnet Explorer:**
1. Ve a la pestaña "Write Contract"
2. Conecta tu wallet
3. Busca la función `withdraw`
4. Ingresa la cantidad en wei (ej: 500000000000000000 para 0.5 ETH)
5. Click en "Write"


### 3. Consultar Balance

Para ver tu balance en la bóveda:

**Desde Sepolia Testnet Explorer:**
1. Ve a la pestaña "Read Contract"
2. Busca `getVaultBalance` o `vault`
3. Ingresa tu dirección
4. Click en "Query"


## Validaciones y Restricciones

### Al Depositar:
- ✅ El valor enviado debe ser mayor a 0
- ✅ El balance total + depósito no debe exceder `BANK_CAP`

### Al Retirar:
- ✅ El monto debe ser mayor a 0
- ✅ El monto no debe exceder tu balance en la bóveda
- ✅ El monto no debe exceder `WITHDRAWAL_LIMIT`
- ✅ Protección contra reentrancia

## Casos de Error

El contrato puede revertir con los siguientes errores:

| Error | Causa |
|-------|-------|
| `TransactionFailed("no eth received")` | Intentaste depositar 0 ETH |
| `TransactionFailed("tx failed")` | Falló la transferencia de ETH |
| `BankCapReached(totalBalance)` | Se alcanzó el límite global de depósitos |
| `InvalidAmount(amount)` | Monto de retiro inválido (0, excede balance o límite) |

## Prácticas de Seguridad Implementadas

- ✅ **Errores personalizados**: Uso de custom errors en lugar de strings en require
- ✅ **Checks-Effects-Interactions**: Patrón implementado en función withdraw
- ✅ **Protección contra reentrancia**: Modifier `reentrancyGuard` implementado
- ✅ **Variables immutable**: Límites definidos en deployment
- ✅ **Validaciones exhaustivas**: Modificadores para validar condiciones
- ✅ **Comentarios NatSpec**: Documentación completa del código
- ✅ **Eventos**: Trazabilidad de todas las operaciones


## Contribuciones

Este es un proyecto educativo. Si encuentras algún problema o tienes sugerencias, no dudes en abrir un issue o pull request.

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## Autor

**Ayelen Etchegoyen**

---

⚠️ **RECORDATORIO IMPORTANTE**: Este contrato es solo para propósitos educativos. No utilizar con fondos reales en mainnet. Siempre realiza auditorías de seguridad profesionales antes de desplegar contratos en producción.