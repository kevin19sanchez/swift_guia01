//
//  ViewController.swift
//  Guia01
//
//  Created by kevin on 24/9/18.
//  Copyright © 2018 kevin. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import AVFoundation
import SDWebImage

class ViewController:  UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //No olvide asociar el outlet chistesCollection desde la interfaz grafica
    @IBOutlet weak var chistesCollection: UICollectionView!
    
    //Listados de chistes
    var chistesList:[Chiste] = [Chiste]();
    
    //Identificador de la celda
    let cellIdentifier:String = "chisteCell"
    
    //Control para refrescar el contenido
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //definimos el datasource y delegado para nuestro CollectionView
        self.chistesCollection.dataSource = self
        self.chistesCollection.delegate = self
        
        //Invocamos al método refresh que recargará todo el contenido
        //desde descargar del webservice hasta la recarga de la tabla.
        self.refresh()
        
        //Refresh control
        //definimos la acción de pull to refresh y se la añadimos al collectionView
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        chistesCollection.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     //Recargar contenido
    @objc func refresh(){
        //imprimimos la accion en log
        print("Refresh content")
        //Cargamos el contenido utilizando la librería alamofire
        Alamofire.request("http://34.211.243.185:8080/chistes").responseJSON{
            response in
            switch response.result{
            //si no hay errores regargamos datos
            case .success:
                self.parse(data: JSON(response.result.value!))
            //si hay errores, mostramos el error en consola y finalizamos
            //la acción de refrescar
            case .failure(let error):
                print(error)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    //obtenemos los resultados desde el json
    //reasignamos la lista de chistes.
    //Para todas las operaciones utilizamos propiedades
    //exclusivas de SwiftyJSON
    func parse(data:JSON){
        //borramos chistes previos
        self.chistesList.removeAll()
        //iteramos el array inicial
        for item in data.arrayValue{
            //creamos una instancia de chiste
            //posteriormente le asignamos los atributos
            let chiste:Chiste = Chiste()
            chiste.nombre = item["nombre"].string!
            chiste.texto = item["texto"].string!
            chiste.imagePath = item["image"].string!
            
            //agregamos el elemento a la lista de chistes
            self.chistesList.append(chiste)
        }
        
        //recargamos el contenido en el collectionView
        self.chistesCollection.reloadData()
        //detenemos la funcion de cargar
        self.refreshControl.endRefreshing()
    }
    
    //Funcion de hablar
    func speak(text:String!){
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)//texto a leer
        utterance.voice = AVSpeechSynthesisVoice(language: "es-ES")//lenguaje
        utterance.rate = 0.4//velocidad
        synthesizer.speak(utterance)
    }
    
    //cuenta el numero de elementos.
    //La funcion es obligatoria.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return self.chistesList.count
    }
    
    //Inicializacion de cada celda del collection
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)-> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! ChisteCell
            cell.nombre.text = self.chistesList[indexPath.item].nombre;
            let imagepath = "http://34.211.243.185:8080/images/" + self.chistesList[indexPath.item].imagePath!
            print(imagepath)
            print(cell.nombre.text!)
            //Utilizamos SDWebImage para descargar imágenes
            cell.image.sd_setImage(with: URL(string:imagepath), placeholderImage: UIImage(named: "emoji.png"))
            return cell;
    }
    
    //capturamos el evento click y ejecutamos la llamada al la funcion
    //de texto a voz
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.speak(text: self.chistesList[indexPath.row].texto)
    }
}

