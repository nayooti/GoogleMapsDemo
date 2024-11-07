import UIKit
import GoogleMaps
import GooglePlaces

public class MapController: UIViewController {

    let key = "YOUR_API_KEY"

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        GMSServices.provideAPIKey(key)
        view = GMSMapView()
    }
}

/*
import UIKit
import GoogleMaps

public class MapController: UIViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
//        view.backgroundColor = .red

        GMSServices.provideAPIKey(key)
        view = GMSMapView()
    }
}

*/
