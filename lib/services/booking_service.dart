import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api.dart';
import '../models/chuyen.dart';
import '../models/tuyenduong.dart';
import '../models/benxe.dart';
import '../models/xe.dart';
import '../models/loaixe.dart';
import '../models/khachhang.dart';
import '../models/ve.dart';
import '../models/trip_info.dart';

class BookingService {
  Future<Ve> getVeById(int id) async {
    final r = await Api.get('/ve/$id');
    return Ve.fromJson(r.data);
  }

  Future<KhachHang> getKhachHang(int id) async {
    final r = await Api.get('/khachhang/$id');
    return KhachHang.fromJson(r.data);
  }

  Future<Chuyen> getChuyen(int id) async {
    final r = await Api.get('/chuyen/$id');
    return Chuyen.fromJson(r.data);
  }

  Future<TuyenDuong> getTuyenDuong(int id) async {
    final r = await Api.get('/tuyenduong/$id');
    return TuyenDuong.fromJson(r.data);
  }

  Future<BenXe> getBenXe(int id) async {
    final r = await Api.get('/benxe/$id');
    return BenXe.fromJson(r.data);
  }

  Future<Xe> getXe(int id) async {
    final r = await Api.get('/xe/$id');
    return Xe.fromJson(r.data);
  }

  Future<LoaiXe> getLoaiXe(int id) async {
    final r = await Api.get('/loaixe/$id');
    return LoaiXe.fromJson(r.data);
  }

  Future<TripInfoDTO> buildTripInfoFromVe(int veId) async {
    final ve = await getVeById(veId);
    final kh = await getKhachHang(ve.khachHangId);
    final ch = await getChuyen(ve.chuyenId);
    final td = await getTuyenDuong(ch.tuyenDuongId);
    final benDi = await getBenXe(td.benDi);
    final benDen = await getBenXe(td.benDen);
    final xe = await getXe(ch.xeId);
    final lx = await getLoaiXe(xe.loaiXeId);

    return TripInfoDTO(
      nhaXe: 'Chuyến ${ch.chuyenName}',
      loaiXe: lx.name,
      bienSo: xe.bienSo,
      gioDi: ch.ngayGio,
      benDi: benDi.name,
      benDen: benDen.name,
      giaVe: ve.veGia,
      khName: kh.khachHangName,
      khSdt: kh.sdt,
      khEmail: kh.email,
    );
  }
}
