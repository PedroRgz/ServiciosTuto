import UIKit
import Alamofire

//Creamos una estructura para contener nuestro objeto JSON y modelarlo a nuestra conveniencia
//Codable nos permitirá serializar la clase - a partir de Swift 4
struct Human:Codable {
    let user:String
    let age:Int
    let isHappy:Bool
}

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
        
        //Utilizamos Alamofire para hacer la petición de los datos en vez de URLSession
        //el primer parámetro será un URL
        //method -> es un enum -> puede utilizar los metodos de HTTP
        //por ahora no necesitamos parámetros, por lo que será nulo
        //los demás parámetros son opcionales, por lo que serán borrados: , encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>, interceptor: <#T##RequestInterceptor?#>, requestModifier: <#T##Session.RequestModifier?##Session.RequestModifier?##(inout URLRequest) throws -> Void#>
        AF.request(endpoint, method: .get, parameters: nil).responseData { (response:AFDataResponse<Data>) in
            //primero evaluamos si viene un error
            if response.error != nil{
                print("Surgió un error inesperado")
                return
            }
            
            //Obtenemos la información consultada que será un JSON
            guard let dataFromService = response.data,
                  //Ahora nuestro objeto JSON será modelado de acuerdo a la estructura Human
                  let humanModel:Human = try? JSONDecoder().decode(Human.self, from: dataFromService) else {
                return
            }
            
            //TODOS LOS LLAMADOS A LA UI SE HACEN EN EL HILO PRINCIPAL -> ya que por defecto los servicios se ejecutan en un hilo secundario
            DispatchQueue.main.async {
                //Asignamos los valores para mostrar en la UI
                self.statusLabel.text = humanModel.isHappy ? "Es feliz!":"Es triste"
                self.nameLabel.text = humanModel.user
                
                //detenemos el loader
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

