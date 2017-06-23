//
//  GameScene.swift
//  Hoppy Bunny
//
//  Created by George Hong on 6/20/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import SpriteKit
enum GameSceneState {
    case active, gameOver
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var sinceTouch : CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 100
    let scrollSpeed2: CGFloat = 50
    let scrollSpeed3: CGFloat = 20
    var obstacleSource: SKNode!
    var obstacleLayer: SKNode!
    var buttonRestart: MSButtonNode!
    var scoreLabel: SKLabelNode!
    var points = 0
    var scrollLayer2: SKNode!
    var scrollLayer3: SKNode!
    
    /* Game management */
    var gameState: GameSceneState = .active
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        /* Recursive node search for 'hero' (child of referenced node) */
        hero = self.childNode(withName: "//hero") as! SKSpriteNode
        
        /* Set reference to scroll layer node */
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        /* Set reference to scroll layer 2 node */
        scrollLayer2 = self.childNode(withName: "scrollLayer2")
        
        /* Set reference to scroll layer 3 node */
        scrollLayer3 = self.childNode(withName: "scrollLayer3")
        
        /* Set reference to obstacle Source node */
        obstacleSource = self.childNode(withName: "//obstacle")
        
        /* Set reference to obstacle layer node */
        obstacleLayer = self.childNode(withName: "obstacleLayer")
        
        /* Set reference to score Label node */
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        /* Set UI connections */
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene?.scaleMode = .aspectFill
            
            /* Restart game scene */
            skView?.presentScene(scene)
            
        }
        
        /* Hide restart button */
        buttonRestart.state = .MSButtonNodeStateHidden
        
        /* Reset Score label */
        scoreLabel.text = "\(points)"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Disbale touch if game state is not active */
        if gameState != .active {return}
        
        /* Reset velocity, helps improve response against cumulative falling velocity */
        hero.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        /* Called when a touch begins */
        
        /* Apply vertical impulse */
        hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))
        
        /* Apply subtle rotation */
        hero.physicsBody?.applyAngularImpulse(1)
        
        /* Reset touch timer */
        sinceTouch = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Skip game update if game no longer active */
        if gameState != .active { return }
        
        /* Called before each frame is rendered */
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 400 {
            hero.physicsBody?.velocity.dy = 400
        }
        
        /* Apply falling rotation */
        if sinceTouch > 0.2 {
            let impulse = -30000 * fixedDelta
            hero.physicsBody?.applyAngularImpulse(CGFloat(impulse))
        }
        
        /* Clamp rotation */
        hero.zRotation.clamp(v1: CGFloat(-90).degreesToRadians(), CGFloat(30).degreesToRadians())
        hero.physicsBody?.angularVelocity.clamp(v1: -1, 3)
        
        /* Update last touch timer */
        sinceTouch += fixedDelta
        
        /* Process world scrolling */
        scrollWorld()
        
        updateObstacles()
        
        spawnTimer+=fixedDelta
    }
    
    func scrollWorld() {
        /* Scroll World */
        scrollLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        scrollLayer2.position.x -= scrollSpeed2 * CGFloat(fixedDelta)
        scrollLayer3.position.x -= scrollSpeed3 * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes */
        for ground in scrollLayer.children as! [SKSpriteNode] {
            
            /* Get ground node position, convert node position to scene space */
            let groundPosition = scrollLayer.convert(ground.position, to: self)
            
            /* Check if ground sprite has left the scene */
            if groundPosition.x <= -ground.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)
                
                /* Convert new node position back to scroll layer space */
                ground.position = self.convert(newPosition, to: scrollLayer)
            }
        }
        
        /* Loop through scroll layer2 nodes */
        for bg_crystals in scrollLayer2.children as! [SKSpriteNode]{
        
            /* Get crystal node position, convert node position to scene space */
            let crystalPosition = scrollLayer2.convert(bg_crystals.position, to: self)
        
            /* Check if crystal sprite has left the scene */
            if crystalPosition.x <= -bg_crystals.size.width / 2 {
                
                /* Reposition crystal sprite to the second starting position */
                let newCPosition = CGPoint(x: (self.size.width / 2) + bg_crystals.size.width, y: crystalPosition.y)
                
                /* Convert new node position back to scroll layer3 space */
                bg_crystals.position = self.convert(newCPosition, to: scrollLayer2)
            }
        }
        
        /* Loop through scroll layer 3 nodes */
        for clouds in scrollLayer3.children as! [SKSpriteNode]{
            
            /* Get cloud node position, convert node position to scene space */
            let cloudPosition = scrollLayer3.convert(clouds.position, to: self)
            
            /* Check if cloud sprite has left the scene */
            if cloudPosition.x <= -clouds.size.width / 2 {
                
                /* Reposition cloud sprite to the second starting position */
                let newClPosition = CGPoint(x: (self.size.width / 2) + clouds.size.width, y: cloudPosition.y)
                
                /* Convert new node position back to scroll layer 3 space */
                clouds.position = self.convert(newClPosition, to: scrollLayer3)
            }
        }
    }
    
    func updateObstacles() {
        /* Update Obstacles */
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode] {
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convert(obstacle.position, to: self)
            
            /* Check if obstacle has left the scene */
            if obstaclePosition.x <= -26 {
                // 26 is one half the width of an obstacle
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.5 {
            
            /* Create a new obstacle by copying the source obstacle */
            let newObstacle = obstacleSource.copy() as! SKNode
            obstacleLayer.addChild(newObstacle)
            
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPoint(x: 352, y: CGFloat.random(min: 210, max: 415))
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convert(randomPosition, to: obstacleLayer)
            
            // Reset spawn timer
            spawnTimer = 0
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /* Hero touches anything, game over */
        
        /* Get references to bodies involved in collision */
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Did our hero pass through the 'goal'? */
        if nodeA.name == "goal" || nodeB.name == "goal" {
            
            /* Increment points */
            points += 1
            
            /* Update score label */
            scoreLabel.text = String(points)
            
            /* We can return now */
            return
        }
        
        /* Load the shake action resource */
        let shakeScene:SKAction = SKAction.init(named: "Shake")!
        
        /* Loop through all nodes  */
        for node in self.children {
            
            /* Apply effect each ground node */
            node.run(shakeScene)
        }
        
        /* Ensure only called while game running */
        if gameState != .active { return }
        
        /* Change game state to game over */
        gameState = .gameOver
        
        /* Stop any new angular velocity being applied */
        hero.physicsBody?.allowsRotation = false
        
        /* Reset angular velocity */
        hero.physicsBody?.angularVelocity = 0
        
        /* Stop hero flapping animation */
        hero.removeAllActions()
        
        /* Show restart button */
        buttonRestart.state = .MSButtonNodeStateActive
    }
    
    
}
