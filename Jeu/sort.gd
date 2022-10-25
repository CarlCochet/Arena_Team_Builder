extends Node
class_name Sort


enum ZoneType {Cercle, Ligne, Baton, Carre, Croix, Marteau}
enum Cible {Libre, Moi, Vide, Allies, Ennemis, Invocations, InvocationsAlliees, InvocationsEnnemies}
enum LDVType {Cercle, Ligne, Diagonal}


var nom: String
var kamas: int = 0
var pa: int
var po: int
var zone: int
var ldv: int
var cooldown: int
var cooldown_global: int
var effets: Array
