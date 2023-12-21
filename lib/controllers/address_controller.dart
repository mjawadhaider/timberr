import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timberr/constants.dart';
import 'package:timberr/models/address.dart';

class AddressController extends GetxController {
  final _supabaseClient = Supabase.instance.client;
  List<Address> addressList = [];
  int selectedIndex = 0;

  String name = "", address = "", country = "", city = "", district = "";
  int pincode = 0;

  Future fetchAddresses() async {
    //get address list
    final response = await _supabaseClient
        .from("Addresses")
        .select()
        .eq(
          "user_id",
          _supabaseClient.auth.user()?.id,
        )
        .execute();
    final responseList = response.data as List;
    for (int i = 0; i < responseList.length; i++) {
      addressList.add(Address.fromJson(responseList[i]));
    }
    update();
  }

  Future getDefaultShippingAddress() async {
    //get default shipping address
    final defaultShippingResponse = await _supabaseClient
        .from("Users")
        .select('default_shipping_id')
        .eq(
          "Uid",
          _supabaseClient.auth.user()?.id,
        )
        .execute();
    int? responseId = defaultShippingResponse.data[0]['default_shipping_id'];
    await fetchAddresses();
    if (responseId != null) {
      for (int i = 0; i < addressList.length; i++) {
        if (addressList.elementAt(i).id == responseId) {
          selectedIndex = i;
          update();
          break;
        }
      }
    }
  }

  Future setDefaultShippingAddress(int index) async {
    if (selectedIndex == index) {
      return;
    }
    selectedIndex = index;
    update();
    await _supabaseClient
        .from("Users")
        .update({'default_shipping_id': addressList.elementAt(index).id})
        .eq(
          "Uid",
          _supabaseClient.auth.user()?.id,
        )
        .execute();
  }

  Future uploadAddress() async {
    final insertData = await _supabaseClient.from("Addresses").insert({
      'full_name': name,
      'address': address,
      'pincode': pincode,
      'country': country,
      'city': city,
      'district': district,
      'user_id': _supabaseClient.auth.user()?.id,
    }).execute();
    if (addressList.isEmpty) {
      selectedIndex = 0;
      //set default user Address Id in the database
      await _supabaseClient
          .from("Users")
          .update({'default_shipping_id': insertData.data[0]})
          .eq(
            "Uid",
            _supabaseClient.auth.user()?.id,
          )
          .execute();
    }
    //add to shipping address list
    addressList.add(
      Address(
        id: insertData.data[0]['id'],
        name: name,
        address: address,
        pincode: pincode,
        country: country,
        city: city,
        district: district,
      ),
    );
    update();
    Get.back();
  }

  Future editAddress(int index, int addressId) async {
    Address newAddress = Address(
        id: addressId,
        name: name,
        address: address,
        pincode: pincode,
        country: country,
        city: city,
        district: district);
    //update values in the database
    await _supabaseClient
        .from("Addresses")
        .update(newAddress.toJson())
        .eq("id", addressId)
        .execute();
    //update the value locally
    addressList[index] = newAddress;
    update();
    Get.back();
  }

  Future deleteAddress(int index) async {
    //check if it is the selected index
    if (index == selectedIndex) {
      if (addressList.length == 1) {
        await kDefaultDialog(
            "Error", "Add a different address before removing this one");
        return;
      } else {
        selectedIndex = 0;
        setDefaultShippingAddress((index == 0) ? 1 : 0);
      }
    }
    //remove address from the database
    await _supabaseClient
        .from("Addresses")
        .delete(returning: ReturningOption.minimal)
        .eq("id", addressList.elementAt(index).id)
        .execute();
    //remove from local list
    addressList.removeAt(index);
    //go back to previous page
    update();
    Get.back();
  }
}
