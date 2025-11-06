package src.domain;

public class LocPadrao {
    private double latitude;
    private double longitude;

    public LocPadrao(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }
    public double getLatitude() {
        return latitude;
    }
    public double getLongitude() {
        return longitude;
    }

    public LocPadrao(LocPadrao l){
        this.latitude = l.getLatitude();
        this.longitude = l.getLongitude();
    }
}
