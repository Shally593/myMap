import { Component, numberAttribute, OnInit } from '@angular/core';
import Map from '@arcgis/core/Map';
import MapView from '@arcgis/core/views/MapView';
import { Geolocation } from '@capacitor/geolocation';
import Graphic from '@arcgis/core/Graphic';
import Point from '@arcgis/core/geometry/Point';
import SimpleMarkerSymbol from '@arcgis/core/symbols/SimpleMarkerSymbol';
import ImageryLayer from '@arcgis/core/layers/ImageryLayer';
import { map } from 'rxjs';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  styleUrls: ['home.page.scss'],
})
export class HomePage implements OnInit {
  mapView: MapView | any ;
  userLocationGraphic: Graphic | any;
  selectedBasemap: string | any;

  constructor() {}
  // private latitude: number | any;
  // private longitude: number | any;

  async ngOnInit() {
    const map = new Map({
      basemap: 'terrain',
      //basemap: "topo-vector"
      //basemap: "streets-vector"
    });

    this.mapView = new MapView({
      container: 'container',
      map: map,
      zoom: 5,
    });

    // this.longitude = 115.16882653396088; -74.04285246963035
    // this.latitude = -8.7187816047730267;40.74328419341538

    //,

    //throw new Error("Method not implemented.")
    // const position = await Geolocation.getCurrentPosition();
    // this.latitude = position.coords.latitude;
    // this.longitude = position.coords.longitude;
    
    let weatherServiceFL = new ImageryLayer({ url: WeatherServiceUrl});
    map.add(weatherServiceFL)

    await this.updateUsertLocationOnMap();
    //simbologi graph marker
    const markerSymbol = new SimpleMarkerSymbol({
      style: 'diamond',          // You can choose other styles like 'square', 'diamond', etc.
      color: [179, 0, 89, 5],  // Set the fill color and opacity (Red with 70% opacity)
      outline: {
        color: [12, 4, 3, 1],   // Set the outline color (Black with 100% opacity)
        width: 1,                         // Set the outline width
      },
      size: 20,                          // Set the size of the marker
    });

    // Tambahkan fitur Point untuk koordinat tambahan ke peta
    for (const coordinate of additionalCoordinates) {
      const geom = new Point({ latitude: coordinate.latitude, longitude: coordinate.longitude });
      const graphic = new Graphic({
        symbol: markerSymbol,
        geometry: geom
      });
      this.mapView.graphics.add(graphic);
      const desiredCenter = new Point ({
        longitude: -74.04285246963035, latitude: 40.74328419341538,
      })
      
      this.mapView.center = desiredCenter
    }
    
    // this.mapView.center = this.userLocationGraphic.geometry as Point;
    // setInterval(this.updateUsertLocationOnMap.bind(this), 1000);

  }
  async changeBasemap() {
    this.mapView.map.basemap = this.selectedBasemap;
  }
  async getLocationService(): Promise<number[]> {
    return new Promise((resolve, reject) => {
      navigator.geolocation.getCurrentPosition((resp) => {
        resolve([resp.coords.latitude, resp.coords.longitude]);
      });
    });
  }

  async updateUsertLocationOnMap() {
    let latLng = await this.getLocationService();
    let geom = new Point({ latitude: latLng[0], longitude: latLng[1] });
    if (this.userLocationGraphic) {
      this.userLocationGraphic.geometry = geom; 
    } else {
      this.userLocationGraphic = new Graphic({
        symbol: new SimpleMarkerSymbol(),
        geometry: geom,
      });
      this.mapView.graphics.add(this.userLocationGraphic);
    };
    
  }
  
}
const WeatherServiceUrl = 'https://mapservices.weather.noaa.gov/eventdriven/rest/services/radar/radar_base_reflectivity_time/ImageServer'


// TUGAS 2 : Sebuah titik di Washington
const additionalCoordinates = [{
  latitude: 38.8044, 
  longitude: -77.00 
}]
