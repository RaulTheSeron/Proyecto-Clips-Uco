;[[Se recomientoda observar el codigo en pantalla completa debido a la longitud de algunos comentarios]]
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;							PLANTILLA PARA GUARDAR INFORMACION DEL MAPA
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------

(deftemplate casilla

	(slot pos (type INTEGER) (default ?NONE) ) 				;Posicion de la casilla
	(slot visitada (type INTEGER)(allowed-values 0 1) (default 0))		;Indica si la casill ya ha sido visitada
	(slot sonido (type INTEGER)(allowed-values 0 1)(default 0))		;Indica si se ha percibido algun sonido en la casilla
	)



(deffacts HechosIniciales
	(posicion 0)
	(mover)
	(contador 1)
	(casilla (pos 0) (visitada 1) (sonido 0)) 				
	(celda 0)						;Hecho que se utilizara para ir mapeando.	
	)

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;									REGLAS DE MOVIMIENTO
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Estas 5 reglas que hacen que Willy se mueva. Cuatro para moverse hacia arrba (Norte), abajo (Sur), izquierda (Oeste) y derecha (Este). 
; Las 4 reglas para moverse tienen la misma prioridad, por lo que el movimineto de Willy es aleatorio (hacia casillas no visitadas).
; La quita regla es para en caso de que Willy esté rodeado de casillas ya visitadas, se mueva a cualquiera de las que tiene alrededor aleatoriamente. 


(defrule MoverN
	(declare (salience 10))

	;Comprobamos si hay norte para que, en caso afirmativo, Willy se desplace al norte.
	(directions $? ?direccion&:(eq ?direccion north) $?)
	?p<-(posicion ?x)
	(celda ?c1)
	
	;Mover es el hecho que necesita Willy para moverse,el cual se negará tras realizar el movimiento para esperar la actualización.
   	?m<-(mover)

	;Si no existe una casilla igual a la celda(posicion de Willy) actualizada, se activa la regla. Esto impide moverse a una casilla/celda visitada.
	(not (exists(casilla(pos ?c2&:(= (+ ?c1 10) ?c2)))))
   =>
   	(retract ?p)
   	(moveWilly north)
  	(assert(posicion north))
	
	;Actualizar es un hecho que se utilizara mas adelante como antecedente para actualizar la posicion de Willy.
  	(assert(Actualizar))
  	(retract ?m)
	)


(defrule MoverS
	(declare (salience 10))
	(directions $? ?direccion&:(eq ?direccion south) $?)
	?p<-(posicion ?x)
	(celda ?c1)
   	?m<-(mover)
	(not (exists(casilla(pos ?c2&:(= (- ?c1 10) ?c2)))))
   =>
   	(retract ?p)
   	(moveWilly south)
  	(assert(posicion south))
  	(assert(Actualizar))
  	(retract ?m)
	)


(defrule MoverE
	(declare (salience 10))
	(directions $? ?direccion&:(eq ?direccion east) $?)
	?p<-(posicion ?x)
	(celda ?c1)
   	?m<-(mover)
	(not (exists(casilla(pos ?c2&:(= (- ?c1 1) ?c2)))))
   =>
   	(retract ?p)
   	(moveWilly east)
  	(assert(posicion east))
  	(assert(Actualizar))
  	(retract ?m)
	)


(defrule MoverW
	(declare (salience 10))
	(directions $? ?direccion&:(eq ?direccion west) $?)
	?p<-(posicion ?x)
	(celda ?c1)
   	?m<-(mover)
	(not (exists(casilla(pos ?c2&:(= (+ ?c1 1) ?c2)))))
   =>
   	(retract ?p)
   	(moveWilly west)
  	(assert(posicion west))
  	(assert(Actualizar))
  	(retract ?m)
	)

; En caso de que Willy este rodeado de casillas visitadas:

(defrule RodeadoVisitadas
  	(directions $? ?direccion $?)
  	?p<-(posicion ?x)
  	?m<-(mover) 
   =>
  	(retract ?p)
  	(moveWilly ?direccion)
  	(assert(posicion ?direccion))
  	(assert(Actualizar))
 	(retract ?m)
	)


;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;							REGLAS DE ACTUALIZACION (TRAS REALIZAR UN MOVIMIENTO)
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Estas reglas necesitaran dos hechos para activarse. El primero es que el hecho Actualizar este afirmado. El segundo es la posicion, la cual activara una regla u otra 
;en funcion de donde se haya movido Willy.


(defrule actualizarN
	(declare(salience 90))
	?c<-(celda ?c1)
	?x<-(contador ?cont)
	?p<-(posicion north)
	?a<-(Actualizar)
   =>
	(assert(celda (+ ?c1 10)))

	; Actualizamos la posicion y marcamos casilla como visitada. +10 por ir al norte. (-10 sur / -1 Este /-1 Oeste) 
	(assert(casilla (pos (+ ?c1 10))(visitada 1)(sonido 0)))

	;Volvemos a afirmar Mover para que Willy se vuelva a desplazar.
	(assert (mover))
	
	; Actualiza el contador de movimientos
	(assert (contador(+ ?cont 1)))
	(retract ?c)

	;Negamos Actualizar para esperar por el siguiente movimiento de Willy.
	(retract ?a)
	(retract ?x)
	)


(defrule actualizarE
	(declare(salience 90))
	?c<-(celda ?c1)
	?x<-(contador ?cont)
	?p<-(posicion east)
	?a<-(Actualizar)
   =>
	(assert(celda (- ?c1 1)))
	(assert(casilla (pos (- ?c1 1))(visitada 1)(sonido 0)))
	(assert (mover))
	(assert (contador(+ ?cont 1)))
	(retract ?c)
	(retract ?a)
	(retract ?x)		
	)


(defrule actualizarW
	(declare(salience 90))
	?c<-(celda ?c1)
	?x<-(contador ?cont)
	?p<-(posicion west)
	?a<-(Actualizar)
   =>
	(assert(celda (+ ?c1 1)))
	(assert(casilla (pos (+ ?c1 1))(visitada 1)(sonido 0)))
	(assert (mover))
	(assert (contador(+ ?cont 1)))
	(retract ?c)
	(retract ?a)		
	(retract ?x)
	)


(defrule actualizarS
	(declare(salience 90))
	?c<-(celda ?c1)
	?x<-(contador ?cont)
	?p<-(posicion south)	
	?a<-(Actualizar)
	
   =>
	(assert(celda (- ?c1 10)))
	(assert(casilla (pos (- ?c1 10))(visitada 1)(sonido 0)))
	(assert (mover))
	(assert (contador(+ ?cont 1)))
	(retract ?c)
	(retract ?a)	
	(retract ?x)
)



;----------------------------------------------------------------------------------------------------------------------------------------------------------------------;								REGLAS PARA EVITAR ARENAS MOVEDIZAS
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------

;Reglas para esquivar arenas movedizas. Cuando Willy se mueva a una casilla y perciba un temblor, este volvera a la posición anterior.
;De este modo, si se mueve al norte y percibe un temblor, volvera al sur.
;En caso de que el temblor venga del norte,movemos y cambiamos la posicion a sur, y afirmamos actualizar. Asi se activa la regla para actualizar al sur.



(defrule temblorN
	(declare(salience 30))
	(percepts Tremor)
	?p<-(posicion north)
	
   =>
	(moveWilly south)
	(retract ?p)

	;Cambiamos la posicion a sur y afirmamos Actualizar para que se active la regla ActualizaS, de modo que sera lo mismo que moverse al sur siempre que se 
	;encuentre peligro en el norte.
	(assert (posicion south))
	(assert(Actualizar))	
	)


(defrule temblorS
	(declare(salience 30))
	(percepts Tremor)
	?p<-(posicion south)
 	
   =>
	(moveWilly north)
	(retract ?p)
	(assert (posicion north))
	(assert(Actualizar))	
	)


(defrule temblorE
	(declare(salience 30))
	(percepts Tremor)
	?p<-(posicion east)
	
   =>
	(moveWilly west)
	(retract ?p)
	(assert (posicion west))
	(assert(Actualizar))	
	)


(defrule temblorW
	(declare(salience 30))
	(percepts Tremor)
	?p<-(posicion west)
	
   =>
	(moveWilly east)
	(retract ?p)
	(assert (posicion east))
	(assert(Actualizar))	
	)


;----------------------------------------------------------------------------------------------------------------------------------------------------------------------;								REGLAS PARA ESQUIVAR Y/O INTENTAR MATAR SERPIENTE
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------
;En caso de que ser perciba un sonido, se disparará la flecha en la direccion en la que este "mirando" Willy. Esto viene indicado por su posicion.
;Tras disparar, se volvera a la casilla anterior.

(defrule serpienteN
	(declare(salience 40))
	(percepts Sound)
	?p<-(posicion north)
	(celda ?c)
   =>
	(fireArrow north)
	(moveWilly south)
	(assert(casilla (pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion south))
	(assert(Actualizar))	
	)


(defrule serpienteS
	(declare(salience 40))
	(percepts Sound)
	?p<-(posicion south)
	(celda ?c)
  =>
	(fireArrow south)
	(moveWilly north)
	(assert(casilla (pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion north))
	(assert(Actualizar))	
	)

(defrule serpienteE
	(declare(salience 40))
	(percepts Sound)
	?p<-(posicion east)
	(celda ?c)
   =>
	(fireArrow east)
	(moveWilly west)
	(assert(casilla (pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion west))
	(assert(Actualizar))	
	)

(defrule serpienteW
	(declare(salience 40))
	(percepts Sound)
	?p<-(posicion west)
	(celda ?c)
   =>
	(fireArrow west)
	(moveWilly east)
	(assert(casilla (pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion east))
	(assert(Actualizar))	
	)

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------		;						REGLAS EM CASO DE NOTAR TEMBLOR Y ESCUCHAR A LA SERPIENTE A LA VEZ
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------
(defrule SerpienteTemblorN
	(declare (salience 60))
	?p<-(posicion north)
	(percepts Sound Tremor)
	(celda ?c)
   =>
	(fireArrow north)
	(moveWilly south)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion south))
	(assert (Actualizar))
	)


(defrule SerpienteTemblorS
	(declare (salience 60))
	?p<-(posicion south)
	(percepts Sound Tremor)
	(celda ?c)
   =>
	(fireArrow south)
	(moveWilly north)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion north))
	(assert (Actualizar))
	)


(defrule SerpienteTemblorE
	(declare (salience 60))
	?p<-(posicion east)
	(percepts Sound Tremor)
	(celda ?c)
   =>
	(fireArrow east)
	(moveWilly west)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion west))
	(assert (Actualizar))
	)


(defrule SerpienteTemblorW
	(declare (salience 60))
	?p<-(posicion west)
	(percepts Sound Tremor)
	(celda ?c)
   =>
	(fireArrow west)
	(moveWilly east)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion east))
	(assert (Actualizar))
	)

(defrule TemblorSerpienteN
	(declare (salience 50))
	?p<-(posicion north)
	(percepts Tremor Sound)
	(celda ?c)
   =>
	(moveWilly south)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion south))
	(assert (Actualizar))
	)


(defrule TemblorSerpienteS
	(declare (salience 50))
	?p<-(posicion south)
	(percepts Tremor Sound)
	(celda ?c)
   =>
	(moveWilly north)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion north))
	(assert (Actualizar))
	)


(defrule TemblorSerpienteE
	(declare (salience 50))
	?p<-(posicion east)
	(percepts Tremor Sound)
	(celda ?c)
   =>
	(moveWilly west)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion west))
	(assert (Actualizar))
	)


(defrule TemblorSerpienteW
	(declare (salience 50))
	?p<-(posicion west)
	(percepts Tremor Sound)
	(celda ?c)
   =>
	(moveWilly east)
	(assert(casilla(pos ?c)(visitada 1)(sonido 1)))
	(retract ?p)
	(assert (posicion east))
	(assert (Actualizar))
	)

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------		;						REGLAS PARA EVITAR QUE WILLY MUERA POR AGOTAMIENTO
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------

(defrule Agotado
	(declare(salience 100))
	(contador 999)
	?p<-(posicion ?x)
=>
	(retract ?p))




