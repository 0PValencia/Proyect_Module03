SimpleDEX - Intercambio Simple de Tokens ERC20

Este proyecto implementa un DEX (Intercambio Descentralizado) básico utilizando contratos inteligentes en Solidity. Permite agregar liquidez, retirar liquidez e intercambiar tokens ERC20 entre dos tokens definidos por el owner.

 Contratos Incluidos

- `TokenA.sol`: Token ERC20 básico con función `mint()` accesible solo por el owner.
- `TokenB.sol`: Otro token ERC20 similar a `TokenA`, utilizado para hacer swaps en el DEX.
- `SimpleDEX.sol`: Contrato principal que permite agregar liquidez, hacer intercambios y consultar precios.

---

 Cómo desplegar los contratos en Remix

### 1. Preparación
- Abre [Remix IDE](https://remix.ethereum.org/)
- Asegúrate de estar en la pestaña **"Solidity"**
- Conéctate con Metamask usando la red deseada (por ejemplo: Sepolia)

 2. Desplegar `TokenA`
1. Carga el contrato `TokenA.sol`
2. Compila
3. Ve a la pestaña **Deploy & Run Transactions**
4. Asegúrate de que esté seleccionada la red "Injected Provider - Metamask"
5. Da clic en `Deploy`
6. Copia la dirección del contrato desplegado (la necesitarás para el DEX)

 3. Desplegar `TokenB`
Haz el mismo proceso con `TokenB.sol`.

 4. Desplegar `SimpleDEX`
1. Selecciona el contrato `SimpleDEX.sol`
2. En los campos de constructor, ingresa las **direcciones de TokenA y TokenB** que copiaste
3. Da clic en `Deploy`
4. Acepta en Metamask

---

 🧪 Cómo probar el contrato

 A. Agregar Liquidez

1. Asegúrate de tener `TokenA` y `TokenB` en tu wallet (puedes usar `mint()`)
2. Ejecuta `approve()` desde cada contrato token:
   ```solidity
   TokenA.approve(dexAddress, amountA);
   TokenB.approve(dexAddress, amountB);
