//creation d'une classe
import Foundation
//======================
class UserDefaultsManager {
    // Méthode pour savoir si une clé exist ou pas
    func doesKeyExist(theKey: String) -> Bool {
        if UserDefaults.standard.object(forKey: theKey) == nil {
            return false
        }
        return true
    }
    
    //Méthode pour sauvegarder une information
    func setKey(theValue: AnyObject, theKey: String) {
        UserDefaults.standard.set(theValue, forKey: theKey)
    }
    
    //Méthode pour eliminer la clé
    func removeKey(theKey: String) {
        UserDefaults.standard.removeObject(forKey: theKey)
    }
    
    //Méthode pour chercher une valeur
    func getValue(theKey: String) -> AnyObject {
        return UserDefaults.standard.object(forKey: theKey) as AnyObject
    }
}
//======================

