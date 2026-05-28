//
//  ContentView.swift
//  Snaek
//
//  Created by Invitado on 27/05/26.
//

import SwiftUI

struct coord : Hashable {
    let id = UUID()
    var x:Int
    var y:Int
}

struct ContentView: View {
    let celSize = 25
    @State private var manzanaCoord: coord = coord(x:15,y:16)
    @State private var manzanaComida = false
    @State private var cuerpo:Array<coord> = [coord(x:12,y:12)]
    @State private var direccion:Array<CGFloat> = [0,0]
    @State private var highscore: Int = 0
    @State private var score: Int = 0
    @State private var bodySet:Set<coord> = Set()
    @State private var juegoCorriendo = false

    var body: some View {
        VStack {
            //Marcadores
            HStack {
                Label("Highscore: \(highscore)", systemImage: "trophy.fill")
                    .font(.headline)
                Spacer() // Separa los dos labels a los extremos
                Label("Score: \(score)", systemImage: "apple.logo")
                    .font(.headline)
            }
            .padding() // Margen interno para los marcadores
            Spacer()
            ZStack{
                ForEach(cuerpo.indices){i in
                    RoundedRectangle(cornerRadius: 5)
                        .position(x: CGFloat(cuerpo[i].x * celSize),y: CGFloat(cuerpo[i].y * celSize))
                }
                RoundedRectangle(cornerRadius: 5)
                    .position(x:CGFloat(manzanaCoord.x * celSize), y: CGFloat(manzanaCoord.y * celSize))
            }.gesture(DragGesture().onEnded{value in guardarDireccion(value)})
            Spacer() // Empuja los marcadores arriba y el botón abajo
            
            //Botón de JUGAR
            HStack {
                Button(action: iniciarJuego) {
                    Label("JUGAR", systemImage: "play.fill")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity) // Usa el ancho disponible
                        .background(Color.blue)
                        .cornerRadius(10)
                        .opacity(juegoCorriendo ? 0: 1)
                }
            }
            .padding() // Margen interno para el área del botón
        }
    }
    func guardarDireccion(_ value: DragGesture.Value){
        if value.translation.width > value.translation.height{
            direccion[0] = value.translation.width/abs(value.translation.width)
        }else{
            direccion[1] = value.translation.height/abs(value.translation.height)
        }
    }
    
    func iniciarJuego() -> Void{
        //Estoy usando un timer como "game loop", la vdd esto solo funciona porque es el juego
        //de la serpiente
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true){timer in
            ///SERPIENTE
            //muevo la serpiente
            var lastPos = cuerpo[0]
            
            cuerpo[0].x += Int(direccion[0])
            cuerpo[0].y += Int(direccion[1])
            
            var i = 1
            while i < cuerpo.count{
                var auxPos = cuerpo[i]
                cuerpo[i] = lastPos
                lastPos = auxPos
                
                i += 1
            }
            
            //checo si choca con algo
            //cuerpo
            bodySet = Set(cuerpo[1...])
            if bodySet.contains(cuerpo[0]){
                perder(timer)
            }
            //pared
            if cuerpo[0].x > 25 || cuerpo[0].x < 0 || cuerpo[0].y > 25 || cuerpo[0].y < 0{
                perder(timer)
            }
            
            ///MANZANA
            if manzanaComida { //si fue comida, se mueve
                manzanaCoord = randCoord()
            } else { //si no, checa si fue comida
                if cuerpo[0] == manzanaCoord{
                    manzanaComida = true
                }
            }
        }
    }
    
    func perder(_ timer:Timer){
        juegoCorriendo = false
        timer.invalidate()
    }
    
    func randCoord() -> coord{
        return coord(x:Int.random(in: 0...25),y:Int.random(in: 0...25))
    }

}

