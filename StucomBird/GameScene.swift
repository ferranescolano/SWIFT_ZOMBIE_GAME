//
//  GameScene.swift
//  StucomBird
//
//  Created by DAM on 10/4/18.
//  Copyright © 2018 DAM. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
var Score:Int = 0
// Necesario para tratar con colisiones SKPhysicsContactDelegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // Guía oficial de Apple sobre SpriteKit
    /* https://developer.apple.com/documentation/spritekit */
    
    // Scene: es el nodo raíz de todos los objetos SpriteKit que se desplegarán en una vista.
    // Para desplegar una "scene" tienes que presentarla desde un objeto SKView
    // Node: un nodo es el bloque fundamental de construcción de casi todo el contenido en SpriteKit.
    // Un nodo puede estar vacío y no dibujar nada en pantalla, para poder dibujar algo en pantalla
    // hay que utilizar subclases de SKNode, por ejemplo SKSpriteNode para dibujar un sprite.
    // SpriteNode: Para crear un SpriteNode, es necesario una textura (imagen) y de un Frame, el cual
    // contiene un rectángulo que define el área que cubrirá el SpriteNode
    // Todo SpriteNode tiene una posición (position) y un punto de anclado (Anchor Point)
    // El punto de anclado de un nodo Sprite es la propiedad que determina que punto de su
    // "Frame" está situado en la posición del sprite (por defecto - (0.5, 0.5) en medio - va de 0.0 a 1.0)
    
    // La propiedad categoryBitMask es un número que define el tipo de objeto que el cuerpo físico del nodo
    // tendrá y es considerado para las colisiones y contactos.
    // La propiedad collisionBitMask es un número que define con qué categorías de objeto este nodo debería colisionar
    // La propiedad contactTestBitMask es un número que define qué colisiones no serán notificadas
    // Si le das a un nodo números de Collision BitMask pero no le das números de contactTestBitMask, significa
    // que los nodos podrán colisionar pero no tendrás manera de saber cuándo ocurrió en código (no se notifica al sistema)
    // Si haces lo contraro (no collisionBitMask pero si contactTestBitMask), no chocarán o colisionarán, pero
    // el sistema te podrá notificar el momento en que tuvieron contacto.
    // Si a las dos propiedades les das valores entonces notificará y a la vez los nodos podrán colisionar
    // De forma predeterminada los cuerpos físicos tienen su propiedad collisionBitMask a todo y su
    // contactBitMask a nada
    var healthIcon = SKSpriteNode()
    var texturaHealth = SKTexture()
    var longitudBarra:Double = 0.0
    var biteSound:AVAudioPlayer = AVAudioPlayer()
    var Seconds:Int = 30
    // Todo elemento en pantalla es un nodo
    var numSaltos:Int = 0
    // Nodo de tipo SpriteKit para la mosquita
    var mosquita = SKSpriteNode()
    // Nodo para el fondo de la pantalla
    var fondo = SKSpriteNode()
    var timeBar = SKSpriteNode()
    // Nodo label para la puntuacion
    var labelPuntuacion = SKLabelNode()
    var puntuacion:Int = 0
    var timeVar:Int = 0
    // Nodos para los tubos
    var tubo1 = SKSpriteNode()
    var tubo2 = SKSpriteNode()
    
    // Texturas de la mosquita
    var texturaMosca1 = SKTexture()
    var texturaMosca2 = SKTexture()
    var texturaMosca3 = SKTexture()
    var texturaMosca4 = SKTexture()
    
    // Textura de los tubos
    var texturaTubo1 = SKTexture()
    var texturaTubo2 = SKTexture()
    
    //Textura de la barra de vida
    var healthBar = SKSpriteNode()
    var healthBarTexture = SKTexture()
    
    // altura de los huecos
    var alturaHueco = CGFloat()
    var barSize = CGFloat()
    
    
    var timer2 = Timer()
    // timer para crear tubos y huecos
    var timer = Timer()
    var timeLeft:Int = 30
    // boolean para saber si el juego está activo o finalizado
    var gameOver = false
    
    // Variables para mostrar tubos de forma aleatoria
    var cantidadAleatoria = CGFloat()
    var compensacionTubos = CGFloat()
    var compensacionBrain = CGFloat()
    
    // Enumeración de los nodos que pueden colisionar
    // se les debe representar con números potencia de 2
    enum tipoNodo: UInt32 {
        case mosquita = 1        // La mosquita colisiona
        case tuboSuelo = 2      // Si choca con el suelo o tubería perderá
        case huecoTubos = 4
        case cerebro = 8
        
        // si pasa entre las tuberías subirá la puntuación
    }
    
    // Función equivalente a viewDidLoad
    override func didMove(to view: SKView) {
        // Nos encargamos de las colisiones de nuestros nodos
        self.physicsWorld.contactDelegate = self
        
       // label.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        timeBar = self.childNode(withName: "healthBar1") as! SKSpriteNode
         barSize = timeBar.size.height
       
       reiniciar()
      time()
        time2()
        
    }
  
    func generateSound(){
        let biteFile = Bundle.main.path(forResource:"biteSound", ofType: "mp3")
   
        do{
            
            try
                biteSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: biteFile!))
  
        }
        catch{
            print(error)
        }
    
    
    
    }

    
    func reiniciar() {
        
        
        
        
        // Creamos los tubos de manera constante e indefinidamente
       /* timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.ponerTubosYHuecos), userInfo: nil, repeats: true)
        */
        // Ponemos la etiqueta con la puntuacion
        ponerPuntuacion()
        
        
        // El orden al poner los elementos es importante, el último tapa al anterior
        // Se puede gestionar también con la posición z de los sprite
        
        crearMosquitaConAnimacion()
        // Definimos la altura de los huecos
        alturaHueco = mosquita.size.height * 1.2
        crearFondoConAnimacion()
        crearSuelo()
       // ponerTubosYHuecos()
        ponerCerebro()
    }
    
    func ponerPuntuacion() {
        labelPuntuacion.fontName = "Arial"
        labelPuntuacion.fontSize = 160
        labelPuntuacion.text = "0"
        labelPuntuacion.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 500)
        labelPuntuacion.zPosition = 2
        self.addChild(labelPuntuacion)
        
    }
    
    func time(){
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.funcTimer), userInfo: nil, repeats: true)
        
        
        texturaHealth = SKTexture(imageNamed: "healthIcon.png")
        
        healthIcon = SKSpriteNode(texture: texturaHealth)
        healthIcon.position = CGPoint(x: -275, y: 140)
        tubo1.zPosition = 0
        
      
       
        addChild(healthIcon)
      
        
       
        
        
    }
    func time2(){
        
         timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.ponerCerebro), userInfo: nil, repeats: true)
    }
    @objc func funcTimer(){
        timeLeft -= 20
        Score += 4
        let label:SKLabelNode = self.childNode(withName: "TimeLabel") as! SKLabelNode
        label.text = String(timeLeft)
 
    
        
  
        if timeLeft <= 0{
          print("Game Over")
            timer.invalidate()
            timer2.invalidate()
            
            let mainMenu = MainMenu(fileNamed: "MainMenu")
            mainMenu?.scaleMode = .aspectFill
            self.view?.presentScene(mainMenu)
        }
        
        if timeLeft > 30 {
            timeBar.size.height = barSize
            timeBar.color = SKColor.yellow
            
            label.text = String(timeLeft - 30)
            label.isHidden = false
        }
        if timeLeft < 30{
            timeBar.color = SKColor.red
            timeBar.size.height = CGFloat(timeLeft * 20)
            label.isHidden = true
        }
    }
    
   
    
    @objc func ponerCerebro(){
      
        
        let moverBrain = SKAction.move(by: CGVector(dx: -3 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width/80))
        
        
        let borrarBrain = SKAction.removeFromParent()
        
        let moverBorrarBrain = SKAction.sequence([moverBrain, borrarBrain])
        
        cantidadAleatoria = CGFloat(arc4random() % UInt32(self.frame.height/3))
        
        compensacionBrain = cantidadAleatoria - self.frame.height / 4
        
        texturaTubo1 = SKTexture(imageNamed: "brain2.png")
        
        tubo1 = SKSpriteNode(texture: texturaTubo1)
        
        tubo1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + texturaTubo1.size().height / 2 + alturaHueco + compensacionBrain)
     
        tubo1.zPosition = 0
        // Le damos cuerpo físico al tubo
        tubo1.physicsBody = SKPhysicsBody(texture: texturaTubo1, alphaThreshold: 0.5, size: texturaTubo1.size())
        
        // Para que no caiga
        tubo1.physicsBody!.isDynamic = false
        // Categoría de collision
        //tubo1.physicsBody!.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        tubo1.physicsBody!.categoryBitMask = tipoNodo.cerebro.rawValue
        
        // con quien colisiona
       tubo1.physicsBody!.collisionBitMask = tipoNodo.mosquita.rawValue
        
        // Hace contacto con
        tubo1.physicsBody!.contactTestBitMask = tipoNodo.mosquita.rawValue
        
        tubo1.run(moverBorrarBrain)
        
        self.addChild(tubo1)
    }
    
   
    
    func crearSuelo() {
        let suelo = SKNode()
       // suelo.position = CGPoint(x: -self.frame.midX, y: -self.frame.height / 2)
       // suelo.position =  CGPoint(x: -self.frame.midX, y: -self.frame.height/4)
        suelo.position = CGPoint(x: -500, y: -130)
        suelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        // el suelo se tiene que estar quieto
        suelo.physicsBody!.isDynamic = false
        
        // Categoría para collision
        suelo.physicsBody!.categoryBitMask = tipoNodo.tuboSuelo.rawValue
        // Colisiona con la mosquita
        suelo.physicsBody!.collisionBitMask = tipoNodo.mosquita.rawValue
        // contacto con el suelo
        suelo.physicsBody!.contactTestBitMask = tipoNodo.mosquita.rawValue
        
        self.addChild(suelo)
    }
    
    func crearFondoConAnimacion() {
        // Textura para el fondo
        let texturaFondo = SKTexture(imageNamed: "fondo5.png")
  
        // Acciones del fondo (para hacer ilusión de movimiento)
        
        // Desplazamos en el eje de las x cada 0.3s

       let movimientoFondo = SKAction.move(by: CGVector(dx: -texturaFondo.size().width, dy: 0), duration: 5)
        

      
        
        let movimientoFondoOrigen = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)
       // let movimientoFondoOrigen = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)
        
        // repetimos hasta el infinito
        let movimientoInfinitoFondo = SKAction.repeatForever(SKAction.sequence([movimientoFondo, movimientoFondoOrigen]))
        
        // Necesitamos más de un fondo para que no se vea la pantalla en negro
        
        // contador de fondos
        var i: CGFloat = 0
        
        while i < 3 {
           
            // Le ponemos la textura al fondo
            fondo = SKSpriteNode(texture: texturaFondo)
        
            let posx = texturaFondo.size().width
            
           
            // Indicamos la posición inicial del fondo
            fondo.position = CGPoint(x: posx * i, y: self.frame.midY)
            
            
            // Estiramos la altura de la imagen para que se adapte al alto de la pantalla
            fondo.size.width = self.frame.width
            
            //fondo.size.height = self.frame.width
            fondo.size.height = self.frame.height/4
            
            // Indicamos zPosition para que quede detrás de todo
            fondo.zPosition = -1
            
            // Aplicamos la acción
            fondo.run(movimientoInfinitoFondo)
            // Ponemos el fondo en la escena
            self.addChild(fondo)
            
            // Incrementamos contador
            i += 1
        }
       
        
    }
    
    func crearMosquitaConAnimacion() {
     
        // Asignamos las texturas de la mosquita
        texturaMosca1 = SKTexture(imageNamed: "Zombie1.png")
        texturaMosca2 = SKTexture(imageNamed: "Zombie2.png")
        texturaMosca3 = SKTexture(imageNamed: "Zombie3.png")
        texturaMosca4 = SKTexture(imageNamed: "Zombie4.png")
        
        // Creamos la animación que va intercambiando las texturas
        // para que parezca que la mosca va volando
        
        // Acción que indica las texturas y el tiempo de cada uno
        let animacion = SKAction.animate(with: [texturaMosca1, texturaMosca2, texturaMosca3, texturaMosca4], timePerFrame: 0.2)
        
        // Creamos la acción que hace que se vaya cambiando de textura
        // infinitamente
        let animacionInfinita = SKAction.repeatForever(animacion)
        
        // Le ponemos la textura inicial al nodo
        mosquita = SKSpriteNode(texture: texturaMosca1)
        // Posición inicial en la que ponemos a la mosquita
        // (0.0, 0.0) es el medio de la pantalla
        // Se puede poner 0.0, 0.0 o bien con referencia a la pantalla
        mosquita.position = CGPoint(x: -300, y: -100)
        
        // Le damos propiedades físicias a nuestra mosquita
        // Le damos un cuerpo circular
        mosquita.physicsBody = SKPhysicsBody(circleOfRadius: texturaMosca1.size().height / 2)
        
        // Al inicial la mosquita está quieta
        mosquita.physicsBody?.isDynamic = false
        
        // Añadimos su categoría
        mosquita.physicsBody!.categoryBitMask = tipoNodo.mosquita.rawValue
        
        // Indicamos la categoría de colisión con el suelo/tubos
        mosquita.physicsBody!.collisionBitMask = tipoNodo.tuboSuelo.rawValue
        
        // Hace contacto con (para que nos avise)
        mosquita.physicsBody!.contactTestBitMask = tipoNodo.tuboSuelo.rawValue | tipoNodo.huecoTubos.rawValue | tipoNodo.cerebro.rawValue
        
        // Aplicamos la animación a la mosquita
        mosquita.run(animacionInfinita)
        
        mosquita.zPosition = 0
        
        // Ponemos la mosquita en la escena
        self.addChild(mosquita)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        if gameOver == false {
            
            
            
            if numSaltos < 2 {
                
            numSaltos  = numSaltos + 1
            // En cuanto el usuario toque la pantalla le damos dinámica a la mosquita (caerá)
            mosquita.physicsBody!.isDynamic = true
            
            // Le damos una velocidad a la mosquita para que la velocidad al caer sea constante
            mosquita.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            
            // Le aplicamos un impulso a la mosquita para que suba cada vez que pulsemos la pantalla
            // Y así poder evitar que se caiga para abajo
            mosquita.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
                 print("Has saltado: \(numSaltos)")
            }
            
        } else {
            // si toca la pantalla cuando el juego ha acabado, lo reiniciamos para volver a jugar
            gameOver = false
            puntuacion = 0
            self.speed = 1
            self.removeAllChildren()
            reiniciar()
            
        }
       
    }
    
    // Función para tratar las colisiones o contactos de nuestros nodos
    func didBegin(_ contact: SKPhysicsContact) {
        // en contact tenemos bodyA y bodyB que son los cuerpos que hicieron contacto
       /* timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)*/
     /*   let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        // Miramos si la mosca ha pasado por el hueco
        if (cuerpoA.categoryBitMask == tipoNodo.mosquita.rawValue && cuerpoB.categoryBitMask == tipoNodo.huecoTubos.rawValue) || (cuerpoA.categoryBitMask == tipoNodo.huecoTubos.rawValue && cuerpoB.categoryBitMask == tipoNodo.mosquita.rawValue) {
            puntuacion += 1
            labelPuntuacion.text = String(puntuacion)
        } else {
            // si no pasa por el hueco es porque ha tocado el suelo o una tubería
            // deberemos acabar el juego
            gameOver = true
            // Frenamos todo
            self.speed = 0
            // Paramos el timer
            timer.invalidate()
            labelPuntuacion.text = "Game Over"
        }*/
        
        let cuerpoA = contact.bodyA
        let cuerpoB = contact.bodyB
        
        if(cuerpoA.categoryBitMask == tipoNodo.mosquita.rawValue && cuerpoB.categoryBitMask == tipoNodo.cerebro.rawValue) || (cuerpoA.categoryBitMask == tipoNodo.cerebro.rawValue && cuerpoB.categoryBitMask == tipoNodo.mosquita.rawValue){
        
           /* if((cuerpoA.categoryBitMask == tipoNodo.cerebro.rawValue) || cuerpoB.categoryBitMask == tipoNodo.cerebro.rawValue){
                
            }
            */
            
            if(cuerpoA.categoryBitMask == tipoNodo.cerebro.rawValue){
                cuerpoA.node?.removeFromParent()
                timeLeft = timeLeft + 1
                print("Has tocado Cerebro")
                
                if timeLeft < 30{
                timeBar.size.height = CGFloat(timeLeft * 20)
                  
                }
                labelPuntuacion.text = String(timeLeft)
               
            }
            if(cuerpoB.categoryBitMask == tipoNodo.cerebro.rawValue){
                cuerpoB.node?.removeFromParent()
                
                timeLeft = timeLeft + 1
                if timeLeft < 30 {
             
                print("Has tocado Cerebro")
               timeBar.size.height = CGFloat(timeLeft * 20)
                    
                }
                labelPuntuacion.text = String(timeLeft)
    }
        }
        
        numSaltos = 0
        
    }
   
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
