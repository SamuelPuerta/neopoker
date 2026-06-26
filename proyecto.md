# NeoPoker — Game Design Document (GDD)

**Versión:** 1.0  
**Estado:** Diseño base completo  
**Plataforma objetivo:** Mobile (iOS & Android) — Flutter + Flame  
**Género:** Card Game / Strategy / Cyberpunk

---

## 1. Visión general

NeoPoker es un juego de póker para móvil ambientado en un mundo cyberpunk noir. Combina la mecánica clásica del Texas Hold'em con una estética neón/futurista y, en sus modos más creativos, con poderes tácticos y eventos de mesa que amplían la tensión estratégica sin romper el equilibrio.

**Premisa narrativa:**  
En la Ciudad Nexo, el poder no se disputa con armas sino en las mesas de juego de los casinos subterráneos controlados por corporaciones. Cada jugador es un operador que busca ascender en el escalafón del crimen digital. Las partidas son transmitidas en vivo por la red oscura. Las fichas son créditos criptográficos. Todo está en juego.

**Pilares de diseño:**

1. **Justicia** — El jugador siempre siente que perdió por decisión, no por injusticia.
2. **Claridad** — Toda mecánica especial es visible, anticipable y simétrica.
3. **Rapidez** — Partidas cortas, repetibles, adaptadas al mobile.
4. **Identidad** — Estética cyberpunk fuerte y coherente en cada pantalla.

---

## 2. Modos de juego

NeoPoker tiene **dos pilares de experiencia** con **dos variantes cada uno** (Casual y Ranked):

```
NeoPoker
├── CLASSIC MODE
│   ├── Classic Casual
│   └── Classic Ranked
└── NEON MODE
    ├── Neon Casual
    └── Neon Ranked
```

---

## 3. Classic Mode — Póker puro

### 3.1 Descripción

Póker Texas Hold'em sin modificadores. La única diferencia con el póker tradicional es la estética y la experiencia visual. El núcleo de habilidad permanece intacto.

**Reglas base:**

- Texas Hold'em estándar
- Ciegas, flop, turn, river, showdown
- Manos de 2–6 jugadores (online o vs bots)
- Rondas de apuestas: check, call, raise, fold, all-in
- Sin poderes, sin eventos aleatorios

### 3.2 Classic Casual

| Parámetro              | Valor                                                    |
| ---------------------- | -------------------------------------------------------- |
| Stack inicial          | 1,000 créditos (softcurrency)                            |
| Mesas disponibles      | Micro (10/20), Low (50/100), Mid (200/400)               |
| Tiempo por decisión    | 30 segundos                                              |
| Penalización por salir | Ninguna                                                  |
| Bots                   | Sí, con dificultad ajustable (Novato / Operador / Elite) |
| Recompensas            | XP + créditos cosméticos                                 |

**Propósito:** Aprender, practicar, jugar sin presión. Ideal para nuevos jugadores y sesiones cortas.

### 3.3 Classic Ranked

| Parámetro                 | Valor                                     |
| ------------------------- | ----------------------------------------- |
| Requisito de acceso       | Nivel 5 de cuenta                         |
| Stack inicial             | Variable según liga                       |
| Tiempo por decisión       | 25 segundos                               |
| Penalización por abandono | -15 puntos de ranking                     |
| Bots                      | No — solo jugadores reales                |
| Recompensas               | Puntos de ranking + emblemas de temporada |

**Sistema de ligas:**

```
Liga           Símbolo    Rango de MMR
────────────────────────────────────────
Circuito       ◈          0 – 999
Operador       ◈◈         1000 – 1999
Hacker         ◈◈◈        2000 – 2999
Fantasma       ◈◈◈◈       3000 – 3999
Nexo Elite     ◈◈◈◈◈      4000+
```

Cada temporada dura 8 semanas. Al final, los jugadores de Nexo Elite compiten en un torneo final por recompensas exclusivas.

**Reglas adicionales Ranked:**

- No se pueden usar skins que alteren la legibilidad de las cartas
- Time bank: cada jugador tiene 60 segundos adicionales por partida para decisiones difíciles
- Anti-collusion: detección automática de patrones de cooperación

---

## 4. Neon Mode — Póker ampliado

### 4.1 Filosofía

El Neon Mode mantiene el 100% de la mecánica de póker base y agrega dos capas opcionales:

- **Eventos de mesa** — condiciones globales que afectan a todos por igual
- **Poderes tácticos** — habilidades de jugador con costo real y contrajuego visible

La clave: **ningún poder o evento decide una mano por sí solo**. Son modificadores de tensión, no atajos de victoria.

### 4.2 Neon Casual

| Parámetro           | Valor                               |
| ------------------- | ----------------------------------- |
| Stack inicial       | 2,000 créditos neón                 |
| Mesas disponibles   | Neon Standard, Neon Hardcore        |
| Eventos de mesa     | Activos, frecuencia media           |
| Poderes             | Habilitados, sin restricción de uso |
| Tiempo por decisión | 35 segundos                         |
| Bots                | Sí, con poderes propios             |

### 4.3 Neon Ranked

| Parámetro           | Valor                                                  |
| ------------------- | ------------------------------------------------------ |
| Requisito de acceso | Nivel 10 + haber jugado 20 partidas Neon Casual        |
| Eventos de mesa     | Activos, frecuencia baja                               |
| Poderes             | Máximo 2 por partida, sin repetición en la misma ronda |
| Tiempo por decisión | 30 segundos                                            |
| Bots                | No                                                     |

**Reglas adicionales Ranked Neon:**

- Cada jugador declara sus 2 poderes antes de que empiece la partida (visibles para todos)
- Los poderes no pueden apilarse: no se pueden usar dos en la misma mano
- Los eventos de mesa se anuncian 1 ronda antes de activarse

---

## 5. Sistema de Eventos de Mesa

Los eventos afectan **toda la mesa por igual** y nunca revelan ni esconden información de cartas individuales.

### 5.1 Tipos de eventos

#### Eventos Visuales (sin efecto mecánico)

Modifican la estética sin alterar las reglas. Su propósito es presión psicológica y ambientación.

| Evento                     | Descripción                                                                           |
| -------------------------- | ------------------------------------------------------------------------------------- |
| **Glitch de Casino**       | La interfaz cambia de paleta de colores brevemente. Las cartas y fichas siguen igual. |
| **Parpadeo Neón**          | Las luces de la mesa "fallan". Animaciones alteradas por 1 ronda.                     |
| **Transmisión en Vivo**    | Aparece un "viewcount" ficticio en la mesa. Sin efecto real.                          |
| **Interferencia de Señal** | Efectos de distorsión sobre los avatares. Solo cosmético.                             |

#### Eventos de Tiempo

Modifican la presión de decisión para todos.

| Evento                    | Efecto                                            | Duración |
| ------------------------- | ------------------------------------------------- | -------- |
| **Overclock Global**      | El tiempo de decisión baja 10 segundos para todos | 1 ronda  |
| **Latencia Alta**         | El tiempo de decisión sube 5 segundos para todos  | 2 rondas |
| **Cuenta Regresiva Neón** | Contador visual urgente aparece encima de todos   | 1 mano   |

#### Eventos de Mesa (mecánicos suaves)

Modifican pequeñas reglas de la mesa. Afectan a todos por igual. Se anuncian antes de activarse.

| Evento                 | Efecto                                                                                                                      | Duración |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------- | -------- |
| **Blackout de Fichas** | La apuesta mínima sube 20% para todos                                                                                       | 1 ronda  |
| **Pot Neón**           | El bote actual se multiplica x1.2 al finalizar la mano                                                                      | 1 mano   |
| **Turno Silencioso**   | Ningún jugador puede hacer raise, solo call o fold                                                                          | 1 mano   |
| **Ciegas Dobles**      | Las ciegas se duplican para esta mano                                                                                       | 1 mano   |
| **Swap Visual**        | Las cartas comunitarias se muestran en orden inverso (river primero visualmente, pero el juego sigue con el orden correcto) | 1 mano   |

#### Eventos Raros (solo Neon Casual)

Alta tensión, baja frecuencia. Nunca aparecen en Neon Ranked.

| Evento               | Efecto                                                                                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Reinicio de Mesa** | Se redistribuyen las posiciones de ciega aleatoriamente                                                                                                 |
| **Bote Fantasma**    | Una fracción del bote (5%) se descuenta y va a un bote acumulado de la partida                                                                          |
| **Mano Oscura**      | Durante esta mano, los jugadores ven sus propias cartas pero no las comunitarias hasta el showdown (efecto visual, las apuestas siguen en orden normal) |

### 5.2 Frecuencia de eventos

| Modo        | Probabilidad por ronda | Máximo eventos simultáneos |
| ----------- | ---------------------- | -------------------------- |
| Neon Casual | 40%                    | 2                          |
| Neon Ranked | 20%                    | 1                          |

---

## 6. Sistema de Poderes

### 6.1 Principios de diseño

Todo poder cumple las 5 reglas fundamentales:

1. **Acceso simétrico** — Todos los jugadores pueden usar los mismos poderes
2. **Costo real** — Gastan energía, cargas o tiempo
3. **Contrajuego visible** — El rival sabe cuándo se usa un poder
4. **Información no revelada** — Ningún poder muestra cartas privadas del rival
5. **Impacto moderado** — No decide una mano solo

⚡ **Cada jugador empieza con 3 puntos de energía por partida.** No se recuperan entre manos. Gastarlos bien es parte del juego.

👁 **Cuando un jugador activa un poder, todos lo ven.** Un ícono aparece sobre su avatar. Nada es secreto.

⚖️ **Ningún poder revela cartas privadas ni altera el mazo.** Solo modifican información, tiempo o condiciones.

🔒 **En Neon Ranked, cada jugador elige 2 poderes antes de la partida, visibles para todos.**

### 6.2 Los 6 poderes rediseñados

#### ANÁLISIS — SCAN (1⚡)

Muestra tus probabilidades de ganar la mano actual según las cartas comunitarias visibles. No revela cartas del rival.

**↳ Contrajuego:** El rival sabe que estás analizando y puede blufear con más confianza o subir para forzarte a decidir bajo presión.

#### PROTECCIÓN — FIREWALL (1⚡)

Bloquea el próximo evento de mesa antes de que se active. Solo funciona una vez por partida.

**↳ Contrajuego:** Si ambos jugadores usan Firewall sobre el mismo evento, los dos se anulan mutuamente y el evento ocurre igual.

#### PRESIÓN — STATIC (1⚡)

Reduce el tiempo de decisión del rival en 8 segundos durante esta mano. Solo funciona una vez por mano.

**↳ Contrajuego:** El rival puede tener Overclock listo para neutralizarlo. Usar Static contra alguien con Overclock es gastar energía en vano.

#### RECUPERACIÓN — OVERCLOCK (1⚡)

Ganas 12 segundos adicionales esta mano. Anula el efecto de Static si alguien te lo acaba de aplicar.

**↳ Contrajuego:** Usarlo en vano (sin que haya Static activo) es gastar 1⚡ por tiempo que quizás no necesitabas.

#### LECTURA — DECRYPT (2⚡)

Revela estadísticas del rival durante la partida: % de manos ganadas en showdown, cuántas veces fue a showdown sin ganar, y cuántas veces hizo fold ante un raise.

**↳ Contrajuego:** El rival también ve que usaste Decrypt y puede cambiar su estilo de juego para desorientar tus lecturas.

#### SABOTAJE — GLITCH (2⚡)

El rival ve sus propias cartas con un efecto de interferencia visual durante 15 segundos. Sus cartas siguen siendo las mismas; solo la visualización se distorsiona.

**↳ Contrajuego:** Si el rival ya decidió su acción antes del Glitch, el efecto llega tarde. Mejor usarlo al inicio de la mano, no al final.

### 6.3 Combos de 2 poderes (Neon Ranked)

| Combo                    | Estilo                                                                       |
| ------------------------ | ---------------------------------------------------------------------------- |
| **SCAN + DECRYPT**       | Analítico. Máxima información — propias probabilidades y patrones del rival. |
| **FIREWALL + OVERCLOCK** | Reactivo. Controla eventos y anula presión de tiempo.                        |
| **STATIC + GLITCH**      | Disruptivo. Presión psicológica máxima, pero cara: 3⚡ totales.              |
| **SCAN + STATIC**        | Agresivo controlado. Analiza antes de presionar al rival.                    |
| **DECRYPT + FIREWALL**   | Conservador. Lee al rival y protege ante eventos negativos.                  |
| **OVERCLOCK + GLITCH**   | Presión asimétrica. Tú ganas tiempo; el rival lo pierde viendo mal.          |

## 7. Progresión y economía

### 7.1 Monedas

| Moneda  | Nombre          | Obtención                        | Uso                                  |
| ------- | --------------- | -------------------------------- | ------------------------------------ |
| Soft    | Créditos (₵)    | Partidas, logros, diario         | Mesas, entradas, bots personalizados |
| Premium | Tokens Neón (◈) | Compra real + desafíos semanales | Cosméticos, pases de temporada       |

**Política de F2P:** Los Tokens Neón compran solo cosméticos. Ningún poder, ventaja de juego o acceso a mesas exclusivas se compra con dinero real.

### 7.2 Niveles de cuenta

Nivel 1–10: Tutorial y Classic Casual  
Nivel 5: Desbloquea Classic Ranked  
Nivel 8: Desbloquea Neon Casual  
Nivel 10: Desbloquea Neon Ranked  
Nivel 15+: Acceso a torneos especiales y mesas VIP

XP por partida:

- Victoria: 100 XP
- Derrota: 40 XP
- Logro de mano especial: +25 XP
- Daily bonus (primera partida del día): +50 XP

### 7.3 Pase de temporada

Cada temporada (8 semanas) tiene un pase con 30 niveles:

- **Pase Gratuito:** Cosméticos básicos, créditos, avatares
- **Pase Neón (₵5 USD):** Cosméticos premium, efectos de mesa, animaciones de showdown, marco de avatar exclusivo

---

## 8. Personajes y avatares

Los jugadores eligen un **Operador** — un arquetipo visual que define su avatar. No afectan las estadísticas.

| Operador   | Descripción visual                                                          |
| ---------- | --------------------------------------------------------------------------- |
| **Vex**    | Hackeadora con implantes oculares cibernéticos, abrigo holográfico          |
| **Cipher** | Analista corporativo con traje de datos y máscara de realidad aumentada     |
| **Ghost**  | Fantasma digital, forma semi-transparente con efectos glitch                |
| **Nyx**    | Corredora de callejones con grafiti bioluminiscente en la piel              |
| **Kronos** | Veterano del casino, prótesis de brazo con fichas integradas                |
| **Pulse**  | DJ underground, auriculares que visualizan las apuestas como olas de sonido |

Cada operador tiene variantes de skin y animaciones de showdown únicas.

---

## 9. Mesas y escenarios

| Mesa                | Estética                                     | Disponible en        |
| ------------------- | -------------------------------------------- | -------------------- |
| **The Underground** | Casino subterráneo, luces rojas, humo        | Classic Casual       |
| **Nexo Exchange**   | Sala corporativa futurista, datos en paredes | Classic Ranked       |
| **Neon District**   | Callejón cyberpunk, lluvia y neón            | Neon Casual          |
| **The Grid**        | Espacio digital abstracto, data visuals      | Neon Casual / Ranked |
| **Apex Tower**      | Piso 99 de una megacorporación               | Neon Ranked          |
| **Ghost Protocol**  | Mesa invisible con jugadores fantasma        | Evento especial      |

---

## 10. HUD e interfaz de juego

### 10.1 Información siempre visible

```
┌─────────────────────────────────────────┐
│  [Avatar]  [Nombre]  [Liga]  [Stack ₵]  │  ← Jugador local (abajo)
│                                         │
│         [Cartas comunitarias]           │  ← Centro de mesa
│              [Bote: ₵ XXX]             │
│                                         │
│  [Avatar]  [Nombre]  [Stack] [Acciones] │  ← Rivales (arriba)
├─────────────────────────────────────────┤
│  [Mis cartas]         [Energía ⚡⚡⚡]  │
│  [FOLD] [CHECK/CALL] [RAISE] [ALL-IN]  │
│  [Poderes disponibles — si Neon Mode]   │
└─────────────────────────────────────────┘
```

### 10.2 Indicadores de estado de poderes

- Ícono de poder activo visible sobre el avatar del jugador que lo usó
- Contador de energía restante visible para todos (no solo el propio)
- Eventos de mesa mostrados en un banner superior con cuenta atrás antes de activarse

### 10.3 Notificaciones de eventos

```
┌──────────────────────────────┐
│ ⚡ EVENTO EN 1 RONDA         │
│ BLACKOUT DE FICHAS           │
│ Las apuestas mínimas +20%    │
└──────────────────────────────┘
```

---

## 11. Manos de póker — referencia rápida

| Rango | Mano            | Ejemplo                   |
| ----- | --------------- | ------------------------- |
| 1     | Royal Flush     | A K Q J 10 del mismo palo |
| 2     | Straight Flush  | 5 6 7 8 9 del mismo palo  |
| 3     | Four of a Kind  | A A A A x                 |
| 4     | Full House      | K K K 2 2                 |
| 5     | Flush           | 5 cartas del mismo palo   |
| 6     | Straight        | 5 cartas consecutivas     |
| 7     | Three of a Kind | Q Q Q x x                 |
| 8     | Two Pair        | J J 4 4 x                 |
| 9     | One Pair        | 7 7 x x x                 |
| 10    | High Card       | La carta más alta         |

---

## 12. Bots de IA

Para Classic Casual y Neon Casual, los bots siguen perfiles de comportamiento:

| Nivel | Nombre   | Comportamiento                                                              |
| ----- | -------- | --------------------------------------------------------------------------- |
| 1     | Novato   | Llama frecuentemente, no blufea, no lee el bote                             |
| 2     | Operador | Balance correcto, foldeadas razonables, blef ocasional                      |
| 3     | Elite    | Lectura de pot odds, blef estratégico, uso inteligente de poderes (en Neon) |

En Neon Mode, los bots Elite usan poderes con lógica contextual: SCAN cuando dudan, FIREWALL antes de eventos negativos, DECRYPT a mitad de partida.

---

## 13. Monetización ética

| Qué se vende            | Qué nunca se vende             |
| ----------------------- | ------------------------------ |
| Skins de avatar         | Poderes o ventajas de juego    |
| Efectos de mesa         | Acceso a información oculta    |
| Animaciones de showdown | Fichas adicionales para ranked |
| Marcos de carta         | Ventajas en torneos            |
| Pase de temporada       | Skip de ligas                  |

**Límite de gasto sugerido visible:** El juego muestra un resumen mensual de gasto y permite configurar límites personales.

---

## 14. Anti-trampa y fairplay

- Detección de patrones de collusion (dos jugadores cooperando)
- Detección de software externo de cálculo de probabilidades en tiempo real
- Reportes de jugadores con revisión humana para casos de ranking (Nexo Elite)
- Ban temporal progresivo por abandono reiterado en partidas Ranked
- Seed del mazo encriptado y verificable (fairness transparente)

---

## 15. Hoja de ruta de desarrollo

### Fase 1 — MVP (Semanas 1–8)

- Motor de póker Texas Hold'em funcional
- Classic Casual con bots nivel 1 y 2
- 2 mesas, 3 operadores
- Sistema de créditos básico
- Lobby y matchmaking local

### Fase 2 — Multiplayer (Semanas 9–16)

- Matchmaking online (Classic Casual y Classic Ranked)
- Sistema de ligas básico (3 ligas)
- 2 operadores adicionales
- Replay de manos

### Fase 3 — Neon Mode (Semanas 17–24)

- Motor de eventos de mesa
- Sistema de poderes (5 poderes base)
- Neon Casual con bots Elite
- Nuevas mesas Neon
- Pase de temporada beta

### Fase 4 — Ecosistema completo (Semanas 25–32)

- Neon Ranked
- Torneos semanales
- Sistema de logros completo
- 6 ligas completas
- Anti-trampa avanzado
- Personalización avanzada

---

## 16. Resumen de diseño

```
NeoPoker = Póker clásico (base intacta)
         + Estética cyberpunk coherente
         + Modos separados (Classic / Neon)
         + Eventos simétricos y anticipables
         + Poderes tácticos con costo y contrajuego
         + Progresión justa sin pay-to-win
         + Partidas cortas adaptadas al mobile
```

El jugador siempre siente que las decisiones importan.  
La suerte existe — pero nunca es excusa suficiente.  
El neon siempre brilla — pero el juego siempre es justo.
