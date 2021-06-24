import UIKit

class ViewController: UIViewController {
    
    //MARK: -Referencias UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchService()
    }

    //MARK: -Método para consumir el servicio
    /*
     // Endpoint: http://www.mocky.io/v2/5e2674472f00002800a4f417
     // 1. Crear expeción de seguridad - Ok
     Esto se realiza porque apple solo permite que sus apps se conecten a servicios mediante HTTPS -> las excepciones de seguridad se implementarán en el archivo info.plist
     // 2. Crear URL con el endpoint.
     // 3. Hacer request con la ayuda de URLSession
     // 4. Transformar respuesta a diccionario
     // 5. Ejecutar Request
     */
    private func fetchService(){
        let endpointString = "http://www.mocky.io/v2/5e2674472f00002800a4f417"
        
        guard let endpoint = URL(string: endpointString) else {
            return
        }
        
        //Iniciamos el loader
        activityIndicator.startAnimating()
        
        URLSession.shared.dataTask(with: endpoint) { (data: Data?, _,error: Error?) in
            
            //primero evaluamos si viene un error
            if error != nil{
                print("Surgió un error inesperado")
                return
            }
            
            //creamos un diccionario para hacer más legible la información que viene de regreso usando la clase JSONSerialization... pero como esta clase no acepta como parametro un optional (data), entonces tenemos que asegurarnos de poderla crear tanto la data como el diccionario:
            guard let dataFromService = data,
                  //el parametro options puede ser un arreglo vacio si no se le harán modificaciones
                  let dictionary = try? JSONSerialization.jsonObject(with: dataFromService, options: []) as? [String:Any] else {
                return
            }
            
            //TODOS LOS LLAMADOS A LA UI SE HACEN EN EL HILO PRINCIPAL -> ya que por defecto los servicios se ejecutan en un hilo secundario
            DispatchQueue.main.async {
                //inicializamos un valor por defecto en nuestro diccionario en caso de que no obtener el valor
                let isHappy = dictionary["isHappy"] as? Bool ?? false
                
                self.statusLabel.text = isHappy ? "Es feliz!":"Es triste"
                self.nameLabel.text = dictionary["user"] as? String
                
                //detenemos el loader
                self.activityIndicator.stopAnimating()
            }
            
        }.resume()
    }
}

