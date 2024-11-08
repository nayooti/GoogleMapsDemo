import UIKit
import GoogleMaps
import GooglePlaces

let apiKey = "YOUR_API_KEY"

struct Place {
    let coordinates: CLLocationCoordinate2D
    let name: String

    init(latitude: Double, longitude: Double, name: String) {
        self.coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.name = name
    }
}

let berlin = Place(latitude: 52.520008, longitude: 13.404954, name: "Berlin")
let munich = Place(latitude: 48.137154, longitude: 11.576124, name: "München")
let potsdam = Place(latitude: 52.398, longitude: 13.052, name: "Potsdam")

public class MapController: UIViewController {

    lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(
            withLatitude: berlin.coordinates.latitude,
            longitude: berlin.coordinates.longitude,
            zoom: 6.0
        )
        return GMSMapView(frame: .zero, camera: camera)
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
        GMSServices.provideAPIKey(apiKey)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        addMarkers()
    }

    private func setupMapView() {
        view = mapView
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
    }

    private func addMarkers() {
        // Berlin Marker
        let berlinMarker = GMSMarker(position: berlin.coordinates)
        berlinMarker.title = berlin.name
        berlinMarker.snippet = "Hauptstadt Deutschland"
        berlinMarker.map = mapView

        // München Marker
        let munichMarker = GMSMarker(position: munich.coordinates)
        munichMarker.title = munich.name
        munichMarker.snippet = "Hauptstadt Bayern"
        munichMarker.map = mapView

        let potsdamMarker = GMSMarker(position: potsdam.coordinates)
        potsdamMarker.title = potsdam.name
        potsdamMarker.snippet = "Potsdam"
        potsdamMarker.map = mapView
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // crashes app
        // mapView.drawLine(from: berlin, to: munich)

        // does not crash app
        mapView.drawLine(from: berlin, to: potsdam)
    }
}

extension GMSMapView {

    enum NavigationType: String {
        case walk = "walking"
        case bike = "bicycling"
        case car = "driving"
    }

    func drawLine(from: Place, to: Place) {
        let startBounds = GMSCoordinateBounds(coordinate: from.coordinates, coordinate: to.coordinates)
        let cameraUpdate = GMSCameraUpdate.fit(startBounds, withPadding: 100)
        animate(with: cameraUpdate)

        fetchPolylineWithOrigin(
            start: CLLocation(latitude: from.coordinates.latitude, longitude: from.coordinates.longitude),
            dest: CLLocation(latitude: to.coordinates.latitude, longitude: to.coordinates.longitude),
            navigationType: .walk
        ) { [weak self] polyline in

            guard let self = self else { return }

            let styles = [
                GMSStrokeStyle.solidColor(.systemBlue),
                GMSStrokeStyle.solidColor(.clear)
            ]

            polyline.strokeWidth = 6
            let lengths = [3, 2]

            polyline.spans = GMSStyleSpans(polyline.path!, styles, lengths as [NSNumber], GMSLengthKind.rhumb)
            // here the crash is happening
            polyline.map = self
        }
    }

    private func fetchPolylineWithOrigin(
        start: CLLocation,
        dest: CLLocation,
        waypoints: [CLLocation] = [],
        navigationType: NavigationType = .car,
        completionHandler: @escaping (_ polyline: GMSPolyline) -> ()
    ) {
        let startString = "\(start.coordinate.latitude),\(start.coordinate.longitude)"
        let destString = "\(dest.coordinate.latitude),\(dest.coordinate.longitude)"

        let directionsAPI = "https://maps.googleapis.com/maps/api/directions/json?"
        let directionsUrlString: String
        if waypoints.isEmpty {
            directionsUrlString = "\(directionsAPI)origin=\(startString)&destination=\(destString)&mode=\(navigationType.rawValue)&key=\(apiKey)"
        } else {
            var waypointsStrings: [String] = []
            for waypoint in waypoints {
                waypointsStrings.append("\(waypoint.coordinate.latitude),\(waypoint.coordinate.longitude)")
            }
            let waypointsString = waypointsStrings.joined(separator: "%7C")
            directionsUrlString = "\(directionsAPI)origin=\(startString)&destination=\(destString)&waypoints=\(waypointsString)&mode=\(navigationType.rawValue)&key=\(apiKey)"
        }

        guard let directionsUrl = URL(string: directionsUrlString) else { return }

        let dataTask = URLSession.shared.dataTask(with: directionsUrl, completionHandler: {
            data, response, error in

            guard let data = data else {
                print("data was nil")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] else {
                print("json parsing failed")
                return
            }
            let defJSON = json

            guard let routesArray = defJSON["routes"] as? [AnyObject] else {
                print("could not extract routes array")
                return
            }
            if routesArray.count != 0 {
                guard let routeDict = routesArray[0] as? [String:AnyObject] else {
                    print("could not extract routeDict")
                    return
                }
                guard let routeOverviewPolyline = routeDict["overview_polyline"] as? [String:AnyObject] else {
                    print("could not extract overview_polyline")
                    return
                }
                guard let points = routeOverviewPolyline["points"] as? String else {
                    print("could not extract points")
                    return
                }

                guard let path = GMSPath(fromEncodedPath: points) else {
                    print("path creation failed")
                    return
                }

                DispatchQueue.main.async {
                    let polyline = GMSPolyline(path: path)
                    completionHandler(polyline)
                }
            }
        })
        dataTask.resume()
    }
}
