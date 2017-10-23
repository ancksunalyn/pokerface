//----------------------//----------------------
import UIKit
//----------------------//----------------------
class ViewController: UIViewController {
    @IBOutlet weak var tempLabel: UILabel!
    //---Liaison des 5 Image Views
    @IBOutlet weak var slot_1: UIImageView!
    @IBOutlet weak var slot_2: UIImageView!
    @IBOutlet weak var slot_3: UIImageView!
    @IBOutlet weak var slot_4: UIImageView!
    @IBOutlet weak var slot_5: UIImageView!
    
    //---Definition des variables pour mettre les cartes du jeu
    var card_blur_1: UIImage!
    var card_blur_2: UIImage!
    var card_blur_3: UIImage!
    var card_blur_4: UIImage!
    var card_blur_5: UIImage!
    
    //-----References aux Views exterieurs
    @IBOutlet weak var bg_1: UIView!
    @IBOutlet weak var bg_2: UIView!
    @IBOutlet weak var bg_3: UIView!
    @IBOutlet weak var bg_4: UIView!
    @IBOutlet weak var bg_5: UIView!
    
    //-----References aux labels
    @IBOutlet weak var keep_1: UILabel!
    @IBOutlet weak var keep_2: UILabel!
    @IBOutlet weak var keep_3: UILabel!
    @IBOutlet weak var keep_4: UILabel!
    @IBOutlet weak var keep_5: UILabel!
    
    //---Definition d'un array d'images
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    
    //---Definition d'un array d'images
    var arrOfCardImages: [UIImage]!
    
    //---Definition d'un array de imageViews (des slots)
    var arrOfSlotImageViews: [UIImageView]!
    
    //---Tableau de tuple que represent le jeu de cartes au complet
    var deckOfCards = [(Int, String)]()
    
    //---Tableau pour les views que sont le background
    var arrOfBackgrounds: [UIView]!
    
    //---Tableau de labels
    var arrOfKeepLabels: [UILabel]!
    
    var permissionToSelectCards = false //Permettre de donner ou ne pas donner la permission de cliquer sur distribuer
    var bet = 0 //Variable utilisé pour contrôler la valeur des mises
    var credits = 2000 //Variable utlisé pour contrôler la valeur des crédits
    var chances = 2 //Variable utilisé pour contrôler les 2 jeux qu'on a dans une main
    var totalBetHand = 0 //Variable utilisé pour contrôler le total misé
    
    //---On cree une instance de la classe pokerHands
    let pokerHands = PokerHands()
    
    //---On cree une instance de la classe UserDefaultsManager pour contrôler les creédits mëme si le jeu est arrêté
    let score = UserDefaultsManager()
    
    //---Tableau de tuple vide qui va être utilisé pour faire l'analyse du jeu
    var handToAnalyse = [(0, ""), (0, ""), (0, ""), (0, ""), (0, "")]
    
    var theHand = [(Int, String)]() //Tuple qu'on va utiliser pour creer tout le jeu de cartes
    var aTimer: Timer? // Variable utilisé pour contrôler l'animation automatiquement
    //----------------------//----------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        //---------------- On verifie s'il y a déjà un credit. S'il n'y a pas, on l'attribue 2000, sinon, on prendre la valeur qui était déjà sauvegardée
        if (!score.doesKeyExist(theKey: "credits")) {
            score.setKey(theValue: credits as AnyObject, theKey: "credits")
        } else {
            credits = score.getValue(theKey: "credits") as! Int
            creditsLabel.text = "CRÉDITS: \(credits)"
        }
        //Fonction qu'on appelle pour reinitialiser des crédits
        resetCredits()
        
        //Fonction pour mettre le bouton de distribution grisé au debut du jeu
        stylizeButtons()
        
        //Fonction qui va mettre des images pour l'animation dans imageViews
        createCardObjectsFromImages()
        
        //--------Fonction qui va remplir tous les arrays
        fillUpArrays()
        
        //---Fonction qui anime les cartes quand elles sont distribues
        prepareAnimations(duration: 0.5,
                          repeating: 5,
                          cards: arrOfCardImages)
        
        //---Fonction qui metrre le style aux slots
        stylizeSlotImageViews(radius: 10,
                              borderWidth: 0.5,
                              borderColor: UIColor.black.cgColor,
                              bgColor: UIColor.yellow.cgColor)
        
        //---Fonction qui mettre le style aux views qui restent au fond
        stylizeBackgroundViews(radius: 10,
                               borderWidth: nil,
                               borderColor: UIColor.black.cgColor,
                               bgColor: nil)
        //---Fonction qui va creer le jeu complet de cartes
        createDeckOfCards()
    }
    //---------Fonction qui va mettre ------------
    func createDeckOfCards() {
        deckOfCards = [(Int, String)]()
        for a in 0...3 {
            let suits = ["d", "h", "c", "s"]
            for b in 1...13 {
                deckOfCards.append((b, suits[a]))
            }
        }
    }
    //------------Fonction qui metrre le style aux slots---------
    func stylizeSlotImageViews(radius r: CGFloat,
                               borderWidth w: CGFloat,
                               borderColor c: CGColor,
                               bgColor g: CGColor!) {
        for slotImageView in arrOfSlotImageViews {
            slotImageView.clipsToBounds = true
            slotImageView.layer.cornerRadius = r
            slotImageView.layer.borderWidth = w
            slotImageView.layer.borderColor = c
            slotImageView.layer.backgroundColor = g
        }
    }
    //---------Fonction qui mettre le style aux views qui restent au fond---------
    func stylizeBackgroundViews(radius r: CGFloat,
                                borderWidth w: CGFloat?,
                                borderColor c: CGColor,
                                bgColor g: CGColor?) {
        for bgView in arrOfBackgrounds {
            bgView.clipsToBounds = true
            bgView.layer.cornerRadius = r
            bgView.layer.borderWidth = w ?? 0
            bgView.layer.borderColor = c
            bgView.layer.backgroundColor = g
        }
    }
    //-----------Fonction qui va remplir tous les arrays-----------
    func fillUpArrays() {
        arrOfCardImages = [card_blur_1, card_blur_2, card_blur_3, card_blur_4,
                           card_blur_5]
        arrOfSlotImageViews = [slot_1, slot_2, slot_3, slot_4, slot_5]
        arrOfBackgrounds = [bg_1, bg_2, bg_3, bg_4, bg_5]
        arrOfKeepLabels = [keep_1, keep_2, keep_3, keep_4, keep_5]
    }
    //--------------Fonction qui va mettre des images pour l'animation dans imageViews-------------
    func createCardObjectsFromImages() {
        card_blur_1 = UIImage(named: "blur1.png")
        card_blur_2 = UIImage(named: "blur2.png")
        card_blur_3 = UIImage(named: "blur3.png")
        card_blur_4 = UIImage(named: "blur4.png")
        card_blur_5 = UIImage(named: "blur5.png")
    }
    ///----------Fonction qui fait l'animation des imageviews qui sont dans l'array arrOfSlotImageViews------
    // Le parametres duration est exterieur, le d est interieur. Cette méthode va recevoir le array que possede les images des cartes
    func prepareAnimations(duration d: Double,
                           repeating r: Int,
                           cards c: [UIImage]) {
        //Pour chaque slot (image view, on va avoir une animation qui dure 0,5 secondes, qui va se repeter 5 fois et qui va utiliser ce que la méthode returnRandomBlurCards va renvoyer comme reponse - c'est a dire, un array avec les images en ordre aleatoire
        //La méthode returnRandomBlurCards reçois comme parametre, le array des images des cartes
        for slotAnimation in arrOfSlotImageViews {
            slotAnimation.animationDuration = d
            slotAnimation.animationRepeatCount = r
            slotAnimation.animationImages = returnRandomBlurCards(arrBlurCards: c)
        }
    }
    ///-----------Fonction qui anime les images de façon  aléatoire--------------------
    func returnRandomBlurCards(arrBlurCards: [UIImage]) -> [UIImage] {
        //array d'image vide que sera renvoyé
        var arrToReturn = [UIImage]()
        //variable qui est égal a mont tableau que j'ai reçu (images des cartes)
        var arrOriginal = arrBlurCards
        //boucle qui va se repeter la quantité de fois qui est égal a la quantité de cartes que j'ai
        for _ in 0..<arrBlurCards.count {
            //ça va donner un numéro aleatoire entre 0 et la quantité d'images
            let randomIndex = Int(arc4random_uniform(UInt32(arrOriginal.count)))
            //dans mon tableau qui est vide, je rajoute celui qui est en index de mon tableau au hasard
            arrToReturn.append(arrOriginal[randomIndex])
            //j'enleve celui qui je viens de rajouter a mon tableau que je vais retourner commme reponse de la méthode, de mon tableau que j'utilise pour faire l'atribuittion aleatoire
            arrOriginal.remove(at: randomIndex)
        }
        return arrToReturn
    }
    //--------------Fonction qui commence l'animation lorsque le bouton play est cliqué dessus-------------
    @IBAction func play(_ sender: UIButton) {
        //--- Si le joueur ne peut plus jouer, le button de distribution ne peut pas être cliqué dessus
        if chances == 0 || dealButton.alpha == 0.5 {
            return
        } else { //sinon, on retire 1 de chance (qui a commencée a 2), parce qu'on ne peut que jouer 2 fois par main
            chances = chances - 1
        }
        //----------- Boolean qu'on va utiliser pour savoir se toute les cartes ont été selecionées par le joueur
        var allSelected = true
        for slotAnimation in arrOfSlotImageViews {
            if slotAnimation.layer.borderWidth != 1.0 {
                allSelected = false
                break
            }
        }
        if allSelected {
            displayRandomCards()
            return
        }
        //---
        for slotAnimation in arrOfSlotImageViews {
            //si la bordure est different de 1.0 ça veut dire que la carte n'est pas selecionée et on peut faire l'animation
            if slotAnimation.layer.borderWidth != 1.0 {
                slotAnimation.startAnimating()
            }
        }
        
        //---On attend l'animation antérieur pour commencer celle là
        aTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                      target: self,
                                      selector: #selector(stopAnimation),
                                      userInfo: nil,
                                      repeats: true)
        
        //---Si les chances et les credits sont finis on bloque les cartes et le bouton pour donner
        if (credits == 0) && (chances == 0) {
            permissionToSelectCards = false
            dealButton.alpha = 0.5
            
        }
    }
    
    //--------Fonction qui arrête l'animation et montre les cartes au hasard----------
    @objc func stopAnimation() {
        // Si la fonction antérieur est terminée, on execute la fonction displayRandomCards si et seulement si toutes les cartes ont fini l'animation
        if (!slot_1.isAnimating) && (!slot_2.isAnimating) && (!slot_3.isAnimating) && (!slot_4.isAnimating) && (!slot_5.isAnimating){
            aTimer?.invalidate()
            aTimer = nil
            displayRandomCards()
        }
    }
    //------------Fonction qui montre les cartes aleatoires------------
    @objc func displayRandomCards() {
        //---La variable va recevoir ce qui est retourné comme cartes aleatoires
        theHand = returnRandomHand()
        //---Cartes de la main
        let arrOfCards = createCards(theHand: theHand)
        //---Montrer les 5 cartes qu'ont été choisi au hasard
        displayCards(arrOfCards: arrOfCards)
        //---Après que le cartes sont distribuée il est permit de les cliquer dessus
        permissionToSelectCards = true
        //---Après que la main est terminé, on prepare les carte pour la prochaine main
        prepareForNextHand()
    }
    //----------Fonction qui va configurer les cartes pour la prochaine main----------
    func prepareForNextHand() {
        //---Si les chances sont finis, on n'a plus la possibilité de cliquer sur les cartes ou de cliquer sur distribuer et en plus les cartes retournent au étage original
        if chances == 0 {
            if credits != 0 {
                permissionToSelectCards = false
                dealButton.alpha = 0.5
                resetCards()
                createDeckOfCards()
                handToAnalyse = [(0, ""), (0, ""), (0, ""), (0, ""), (0, "")]
                chances = 2
                bet = 0
                betLabel.text = "MISE: 0"
                score.setKey(theValue: credits as AnyObject, theKey: "credits")
                totalBetHand = 0
            } else {
                restartButton.isHidden = false
            }
        }
    }
    //-------------Montrer les cartes------------
    func displayCards(arrOfCards: [String]) {
        var counter = 0
        // pour chaque slot, si la bordure du slot est different de 1, c'est a dire que la carte est pas selecione, je peux la donner une nouvelle image
        for slotAnimation in arrOfSlotImageViews {
            if slotAnimation.layer.borderWidth != 1 {
                if chances == 0 {
                    handToAnalyse = removeEmptySlotsAndReturnArray()
                    handToAnalyse.append(theHand[counter])
                }
                slotAnimation.image = UIImage(named: arrOfCards[counter])
            }
            counter = counter + 1
        }
        //----------Si le joueur a déjà joué 2 fois il faut verifier quel est le résultat
        if chances == 0 {
            verifyHand(hand: handToAnalyse)
        }
    }
    //--------------Fonction utilisé au moment d'analiser la main ------------
    func removeEmptySlotsAndReturnArray() -> [(Int, String)] {
        var arrToReturn = [(Int, String)]()
        for card in handToAnalyse {
            if card != (0, "") {
                arrToReturn.append(card)
            }
        }
        return arrToReturn
    }
    //------------Fonction que gère les images chaque main--------------
    func createCards(theHand: [(Int, String)]) -> [String] {
        //---
        let card_1 = "\(theHand[0].0)\(theHand[0].1).png"
        let card_2 = "\(theHand[1].0)\(theHand[1].1).png"
        let card_3 = "\(theHand[2].0)\(theHand[2].1).png"
        let card_4 = "\(theHand[3].0)\(theHand[3].1).png"
        let card_5 = "\(theHand[4].0)\(theHand[4].1).png"
        return [card_1, card_2, card_3, card_4, card_5]
        //---
    }
    //------------Fonction que va creer la main------------
    func returnRandomHand() -> [(Int, String)] {
        //---
        var arrToReturn = [(Int, String)]()
        //---
        for _ in 1...5 {
            //trouver un chiffre en hazard selon le carte que j'ai dans mon array de 52 cartes
            let randomIndex = Int(arc4random_uniform(UInt32(deckOfCards.count)))
            //Ajouter les cartes au hazard (a partir de mes 52 cartes) a mon array theHand (avec 5 cartes)
            arrToReturn.append(deckOfCards[randomIndex])
            deckOfCards.remove(at: randomIndex)
        }
        return arrToReturn
    }
    //---------onction que va verifier la main en utilisant la classe instancié--------
    func verifyHand(hand: [(Int, String)]) {
        if pokerHands.royalFlush(hand: hand) {
            calculateHand(times: 250, handToDisplay: "QUINTE FLUSH ROYALE")
        } else if pokerHands.straightFlush(hand: hand) {
            calculateHand(times: 50, handToDisplay: "QUINTE FLUSH")
        } else if pokerHands.fourKind(hand: hand) {
            calculateHand(times: 25, handToDisplay: "CARRÉ")
        } else if pokerHands.fullHouse(hand: hand) {
            calculateHand(times: 9, handToDisplay: "FULL")
        } else if pokerHands.flush(hand: hand) {
            calculateHand(times: 6, handToDisplay: "COULEUR")
        } else if pokerHands.straight(hand: hand) {
            calculateHand(times: 4, handToDisplay: "QUINTE")
        } else if pokerHands.threeKind(hand: hand) {
            calculateHand(times: 3, handToDisplay: "BRELAN")
        } else if pokerHands.twoPairs(hand: hand) {
            calculateHand(times: 2, handToDisplay: "DEUX PAIRES")
        } else if pokerHands.onePair(hand: hand) {
            calculateHand(times: 1, handToDisplay: "PAIRE")
        } else {
            calculateHand(times: 0, handToDisplay: "ESSAYE ENCORE")
        }
    }
    //-----------Fonction qui calcule combien de credits et de mise il reste encore-------
    func calculateHand(times: Int, handToDisplay: String) {
        credits += (times * bet)
        tempLabel.text = handToDisplay
        creditsLabel.text = "CRÉDITS: \(credits)"
    }
    //-------------Fonction qui contrôle le moment de garger et de plus garger les cartes------------
    @IBAction func cardsToHold(_ sender: UIButton) {
        //---Si on n'a pas de permission pour cliquer sur les cartes on ne va pas faire le on and off
        if !permissionToSelectCards {
            return
        }
        //---Cette partie fait le OFF des cartes
        //Si la carte qui j'ai cliqué dessus a une bordure de 0,5, ça veut dire qu'elle est seleccionée
        if arrOfBackgrounds[sender.tag].layer.borderWidth == 0.5 {
            arrOfSlotImageViews[sender.tag].layer.borderWidth = 0.5
            arrOfBackgrounds[sender.tag].layer.borderWidth = 0.0
            arrOfBackgrounds[sender.tag].layer.backgroundColor = nil
            arrOfKeepLabels[sender.tag].isHidden = true
            //---
            manageSelectedCards(theTag: sender.tag, shouldAdd: false)
        } else { //la on selecione la carte - Cette partie fait le ON des cartes
            arrOfSlotImageViews[sender.tag].layer.borderWidth = 1.0
            arrOfBackgrounds[sender.tag].layer.borderWidth = 0.5
            arrOfBackgrounds[sender.tag].layer.borderColor = UIColor.blue.cgColor
            arrOfBackgrounds[sender.tag].layer.backgroundColor = UIColor(red: 0.0,
                                                                         green: 0.0, blue: 1.0, alpha: 0.5).cgColor
            arrOfKeepLabels[sender.tag].isHidden = false
            manageSelectedCards(theTag: sender.tag, shouldAdd: true)
        }
    }
    //----------Fonction qui met la carte seleccioné et enleve la carte deselecioné dans la main avant de distribuer la deuxième fois----------
    func manageSelectedCards(theTag: Int, shouldAdd: Bool) {
        if shouldAdd {
            handToAnalyse[theTag] = theHand[theTag]
        } else {
            handToAnalyse[theTag] = (0, "")
        }
    }
    //----------Fonction qui contrôle les mises------------
    @IBAction func betButtons(_ sender: UIButton) {
        //---Si le jouer a déjà fait les première clique à lequel il a droit, pas le droit de miser
        if chances <= 1 {
            return
        }
        tempLabel.text = ""

        if sender.tag == 1000 {
            if credits != 0 {
                    bet = credits + totalBetHand // Au cas ou on clique sur tout après avoir cliqué sur les autres boutons de mise
                    betLabel.text = "MISE: \(bet)"
                    credits = 0
                    creditsLabel.text = "CRÉDITS: \(credits)"
                    dealButton.alpha = 1.0
                    resetBackOfCards()
                    totalBetHand = bet
                    return
            }
        }
        //---Variable qui va recevoir la valeur de la mise
        let theBet = sender.tag
        //---Calcul des crédits et mises après que les mises sont faits
        if credits >= theBet {
            bet += theBet
            credits -= theBet
            betLabel.text = "MISE: \(bet)"
            creditsLabel.text = "CRÉDITS: \(credits)"
            dealButton.alpha = 1.0
            totalBetHand += sender.tag
        }
        
        //--- On reset le background des cartes après que le mises sont faites
        resetBackOfCards()
    }
    //-----------Fonction que remettre l'image de back aux cartes--------
    func resetBackOfCards() {
        for back in arrOfSlotImageViews {
            back.image = UIImage(named: "back.png")
        }
    }
    //----------Fonctions que remetrre les cartes au état original---------
    func resetCards() {
        //--------On donne le style initial aux cartes--------
        for index in 0...4 {
            arrOfSlotImageViews[index].layer.borderWidth = 0.5
            arrOfBackgrounds[index].layer.borderWidth = 0.0
            arrOfBackgrounds[index].layer.backgroundColor = nil
            arrOfKeepLabels[index].isHidden = true
        }
        //----------On redonne les 2 chances que le jouer a chaque main
        chances = 2
    }
    //---------S'il n'y a plus de crédits, on le remmetre a 2000------------
    func resetCredits(){
        if (score.doesKeyExist(theKey: "credits")) && (credits == 0){
           credits = 2000
           score.setKey(theValue: credits as AnyObject, theKey: "credits")
           creditsLabel.text = "CRÉDITS: \(credits)"
       }
    }
    //---------Fonction qui recommence le jeu-----------
    
    @IBAction func restart(_ sender: UIButton) {
        credits = 2000
        totalBetHand = 0
        score.setKey(theValue: credits as AnyObject, theKey: "credits")
        creditsLabel.text = "CRÉDITS: \(credits)"
        permissionToSelectCards = false
        dealButton.alpha = 0.5
        resetCards()
        createDeckOfCards()
        resetBackOfCards()
        handToAnalyse = [(0, ""), (0, ""), (0, ""), (0, ""), (0, "")]
        chances = 2
        bet = 0
        betLabel.text = "MISE: 0"
        tempLabel.text = "BONNE CHANCE!"
        restartButton.isHidden = true
    }
    
    //---------Fonction qui mettre le bouton de donner en transparence-----------
    func stylizeButtons(){
        dealButton.alpha = 0.5
    }
//-------------Fonction qui contrôle le bouton de retirer les mises----------
    @IBAction func removeButton(_ sender: UIButton) {
        if chances <= 1 {
            return
        }
        credits += totalBetHand
        creditsLabel.text = "CRÉDITS: \(credits)"
        bet = 0
        betLabel.text = "MISE: \(bet)"
        totalBetHand = 0
        dealButton.alpha = 0.5
    }
}

