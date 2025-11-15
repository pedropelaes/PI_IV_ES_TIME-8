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

    @Override
    public String toString() {return "Latitude: " + this.latitude + ", Longitude: " + this.longitude;}

    @Override
    public boolean equals(Object obj){
        if (this == obj) return true;
        if(obj == null) return false;
        if(this.getClass() != obj.getClass()) return false;
        LocPadrao l = (LocPadrao)obj;
        if(this.latitude != l.latitude || this.longitude != ((LocPadrao) obj).longitude) return false;
        return true;
    }

    @Override
    public int hashCode() {
        int ret = 1;
        ret = ret * 2 + (Double.hashCode(latitude));
        ret = ret * 2 + (Double.hashCode(longitude));
        return ret;
    }

}
