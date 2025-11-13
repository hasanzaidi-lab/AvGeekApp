//
//  MapKitView.swift
//  AvApp
//
//  Created by Hasan Zaidi on 11/11/25.
//

import SwiftUI
import MapKit

public struct MapKitView: View {
    @StateObject private var viewModel: MapKitViewModel
    private let icao24: String
    
    public init(icao24: String) {
        self.icao24 = icao24
        _viewModel = StateObject(wrappedValue: MapKitViewModel())
    }

    init(icao24: String, viewModel: MapKitViewModel) {
        self.icao24 = icao24
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch (viewModel.isLoading, viewModel.errorMessage, viewModel.coordinates.count) {
            case (true, _, _):
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Fetching latest track…")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            case (_, let error?, _):
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundColor(.secondary)
            case (_, _, let count) where count >= 2:
                TrackPolylineMap(coordinates: viewModel.coordinates)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if let callsign = viewModel.callsign, !callsign.isEmpty {
                            Text(callsign)
                                .font(.caption.bold())
                                .padding(8)
                                .background(.ultraThinMaterial, in: Capsule())
                                .padding(10)
                        }
                    }
                if let lastUpdate = viewModel.lastUpdate {
                    Text("Last update \(RelativeDateTimeFormatter.shared.localizedString(for: lastUpdate, relativeTo: .now))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            default:
                Text("Track data unavailable for this aircraft.")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .task(id: icao24) {
            viewModel.loadTrack(for: icao24)
        }
    }
}

private extension RelativeDateTimeFormatter {
    static let shared: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
}

private struct TrackPolylineMap: UIViewRepresentable {
    let coordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.isPitchEnabled = false
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        guard coordinates.count >= 2 else { return }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        if let start = coordinates.first {
            mapView.addAnnotation(FlightTrackAnnotation(kind: .start, coordinate: start))
        }
        
        if let current = coordinates.last {
            mapView.addAnnotation(FlightTrackAnnotation(kind: .current, coordinate: current))
        }
        
        let padding = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: padding, animated: false)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
        final class Coordinator: NSObject, MKMapViewDelegate {
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 3
            renderer.lineJoin = .round
            renderer.lineCap = .round
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? FlightTrackAnnotation else { return nil }
            
            switch annotation.kind {
            case .start:
                let identifier = "FlightStartAnnotation"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                    ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.markerTintColor = .systemGray
                view.glyphImage = UIImage(systemName: "airplane.departure")
                view.glyphTintColor = .white
                view.canShowCallout = false
                return view
            case .current:
                let identifier = "FlightCurrentDot"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.canShowCallout = false
                view.frame = CGRect(origin: .zero, size: CGSize(width: 14, height: 14))
                view.layer.cornerRadius = 7
                view.layer.borderWidth = 2
                view.layer.borderColor = UIColor.white.cgColor
                view.backgroundColor = UIColor.systemGreen
                return view
            }
        }
    }
}

private final class FlightTrackAnnotation: NSObject, MKAnnotation {
    enum Kind {
        case start
        case current
    }
    
    let kind: Kind
    dynamic var coordinate: CLLocationCoordinate2D
    
    init(kind: Kind, coordinate: CLLocationCoordinate2D) {
        self.kind = kind
        self.coordinate = coordinate
    }
}

#Preview {
    MapKitView(icao24: "a7bfa0")
        .padding()
}
